"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.SalesService = void 0;
const common_1 = require("@nestjs/common");
const database_service_1 = require("../../database/database.service");
let SalesService = class SalesService {
    constructor(db) {
        this.db = db;
    }
    /**
     * Procesa una venta transaccional pura:
     * 1. Inserta `sales`
     * 2. Inserta `sale_items`
     * 3. Deduce `current_stock` en `products`
     * 4. Registra `movements` (Kárdex)
     * 5. Actualiza `actual_cash` en `cash_shifts` si es en efectivo
     */
    async processSale(dto) {
        const cashShiftId = dto.cashShiftId || dto.shiftId;
        const ticketNumber = dto.ticketNumber || `T-${Date.now()}`;
        return await this.db.withTransaction(async (client) => {
            var _a, _b, _c, _d;
            // 1. Validar caja abierta
            const shiftRes = await client.query('SELECT status, actual_cash FROM cash_shifts WHERE id = $1 AND store_id = $2 FOR UPDATE', [cashShiftId, dto.storeId]);
            if (shiftRes.rowCount === 0 || shiftRes.rows[0].status !== 'OPEN') {
                throw new common_1.BadRequestException('La caja está inactiva o cerrada');
            }
            // 2. Calcular totales localmente para seguridad
            let subtotal = 0;
            for (const item of dto.items) {
                const price = (_b = (_a = item.unitPrice) !== null && _a !== void 0 ? _a : item.salePrice) !== null && _b !== void 0 ? _b : 0;
                subtotal += item.quantity * price;
            }
            const tax = subtotal * 0.15; // IVA 15% quemado temporalmente para pruebas
            const total = subtotal + tax;
            // 3. Insertar Factura Principal
            const saleRes = await client.query(`INSERT INTO sales (store_id, cash_shift_id, cashier_id, ticket_number, subtotal, tax, total, payment_method, 
         client_id, client_name, cashier_name, payment_currency, amount_received, change_given) 
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14) RETURNING *`, [dto.storeId, cashShiftId, dto.cashierId, ticketNumber, subtotal, tax, total, dto.paymentMethod,
                dto.clientId || null, dto.clientName || null, dto.cashierName || null,
                dto.paymentCurrency || 'NIO', dto.amountReceived || 0, dto.change || 0]);
            const sale = saleRes.rows[0];
            // 4. Iterar ítems (Venta, Deducción e Inventario)
            for (const item of dto.items) {
                const productId = item.productId || item.id;
                const price = (_d = (_c = item.unitPrice) !== null && _c !== void 0 ? _c : item.salePrice) !== null && _d !== void 0 ? _d : 0;
                const lineTotal = item.quantity * price;
                // A. Insertar linea de compra
                await client.query(`INSERT INTO sale_items (sale_id, product_id, quantity, unit_price, subtotal) 
           VALUES ($1, $2, $3, $4, $5)`, [sale.id, productId, item.quantity, price, lineTotal]);
                // B. Extraer stock actual y restar (con bloqueo concurrente preventivo)
                const prodRes = await client.query('SELECT current_stock, uses_inventory FROM products WHERE id = $1 FOR UPDATE', [productId]);
                if (prodRes.rowCount === 0)
                    continue; // producto puede no tener inventario
                if (!prodRes.rows[0].uses_inventory)
                    continue;
                const oldStock = prodRes.rows[0].current_stock;
                const newStock = oldStock - item.quantity;
                await client.query('UPDATE products SET current_stock = $1 WHERE id = $2', [newStock, productId]);
                // C. Asentar en Kárdex
                await client.query(`INSERT INTO movements (store_id, product_id, user_id, type, quantity, balance, reference) 
           VALUES ($1, $2, $3, 'OUT', $4, $5, $6)`, [dto.storeId, productId, dto.cashierId, item.quantity, newStock, `Venta Ticket: ${ticketNumber}`]);
            }
            // 5. Acumular a Caja (Si es Efectivo)
            if (dto.paymentMethod === 'CASH' || dto.paymentMethod === 'Efectivo') {
                const newCash = parseFloat(shiftRes.rows[0].actual_cash) + total;
                await client.query('UPDATE cash_shifts SET actual_cash = $1 WHERE id = $2', [newCash, cashShiftId]);
            }
            return {
                success: true,
                saleId: sale.id,
                id: sale.id,
                ticketNumber: sale.ticket_number || ticketNumber,
                total,
                subtotal,
                tax,
                paymentMethod: dto.paymentMethod,
                items: dto.items,
                clientName: dto.clientName,
                cashierName: dto.cashierName,
                createdAt: sale.created_at,
                message: 'Venta Procesada Satisfactoriamente',
            };
        });
    }
    async findAll(storeId, shiftId, startDate, endDate, storeIds) {
        let sql = 'SELECT * FROM sales WHERE 1=1';
        const params = [];
        if (storeId) {
            sql += ' AND store_id = $' + (params.push(storeId));
        }
        if (storeIds) {
            const ids = storeIds.split(',').map(s => s.trim()).filter(Boolean);
            if (ids.length > 0) {
                const placeholders = ids.map((_, i) => `$${params.length + i + 1}`).join(',');
                sql += ` AND store_id IN (${placeholders})`;
                params.push(...ids);
            }
        }
        if (shiftId) {
            sql += ' AND cash_shift_id = $' + (params.push(shiftId));
        }
        if (startDate) {
            sql += ' AND created_at >= $' + (params.push(startDate));
        }
        if (endDate) {
            sql += ' AND created_at <= $' + (params.push(endDate));
        }
        sql += ' ORDER BY created_at DESC';
        const res = await this.db.query(sql, params);
        return res.rows.map(this.mapSaleRow);
    }
    async findOne(id) {
        const saleRes = await this.db.query('SELECT * FROM sales WHERE id = $1', [id]);
        if (saleRes.rowCount === 0)
            throw new common_1.NotFoundException('Venta no encontrada');
        const itemsRes = await this.db.query(`SELECT si.*, p.description, p.barcode 
       FROM sale_items si 
       LEFT JOIN products p ON si.product_id = p.id 
       WHERE si.sale_id = $1`, [id]);
        const sale = this.mapSaleRow(saleRes.rows[0]);
        sale.items = itemsRes.rows.map(r => ({
            id: r.id,
            productId: r.product_id,
            description: r.description,
            barcode: r.barcode,
            quantity: parseInt(r.quantity),
            unitPrice: parseFloat(r.unit_price),
            subtotal: parseFloat(r.subtotal),
        }));
        return sale;
    }
    async processReturn(saleId, dto) {
        return await this.db.withTransaction(async (client) => {
            var _a;
            // Verify sale exists
            const saleRes = await client.query('SELECT * FROM sales WHERE id = $1', [saleId]);
            if (saleRes.rowCount === 0)
                throw new common_1.NotFoundException('Venta no encontrada');
            const sale = saleRes.rows[0];
            let totalRefund = 0;
            for (const item of dto.items) {
                // Get original sale item price
                const siRes = await client.query('SELECT unit_price FROM sale_items WHERE sale_id = $1 AND product_id = $2', [saleId, item.productId]);
                const unitPrice = siRes.rowCount > 0 ? parseFloat(siRes.rows[0].unit_price) : 0;
                totalRefund += unitPrice * item.quantity;
                // Restore stock
                await client.query('UPDATE products SET current_stock = current_stock + $1 WHERE id = $2', [item.quantity, item.productId]);
                // Get new balance for movement log
                const prodRes = await client.query('SELECT current_stock FROM products WHERE id = $1', [item.productId]);
                const newBalance = ((_a = prodRes.rows[0]) === null || _a === void 0 ? void 0 : _a.current_stock) || 0;
                // Log inventory movement
                await client.query(`INSERT INTO movements (store_id, product_id, user_id, type, quantity, balance, reference)
           VALUES ($1, $2, $3, 'IN', $4, $5, $6)`, [sale.store_id, item.productId, sale.cashier_id, item.quantity, newBalance,
                    `Devolución Venta: ${sale.ticket_number}. ${dto.reason || ''}`]);
            }
            return { success: true, saleId, totalRefund, message: 'Devolución procesada correctamente' };
        });
    }
    async getSalesReport(storeId, startDate, endDate) {
        // 1. Mejores Productos
        const productsRes = await this.db.query(`SELECT p.name, SUM(si.quantity) as count, SUM(si.subtotal) as total 
       FROM sale_items si
       JOIN sales s ON si.sale_id = s.id
       JOIN products p ON si.product_id = p.id
       WHERE s.store_id = $1 AND s.created_at BETWEEN $2 AND $3
       GROUP BY p.name
       ORDER BY total DESC LIMIT 10`, [storeId, startDate, endDate]);
        // 2. Ventas por Método
        const methodsRes = await this.db.query(`SELECT payment_method, SUM(total) as total, COUNT(*) as count
       FROM sales
       WHERE store_id = $1 AND created_at BETWEEN $2 AND $3
       GROUP BY payment_method`, [storeId, startDate, endDate]);
        return {
            topProducts: productsRes.rows.map(r => ({ name: r.name, value: parseFloat(r.total), count: parseInt(r.count) })),
            byMethod: methodsRes.rows.map(r => ({ method: r.payment_method, total: parseFloat(r.total), count: parseInt(r.count) }))
        };
    }
    mapSaleRow(row) {
        return {
            id: row.id,
            total: parseFloat(row.total),
            subtotal: parseFloat(row.subtotal),
            tax: parseFloat(row.tax),
            paymentMethod: row.payment_method,
            ticketNumber: row.ticket_number,
            storeId: row.store_id,
            cashShiftId: row.cash_shift_id,
            cashierId: row.cashier_id,
            cashierName: row.cashier_name,
            clientId: row.client_id,
            clientName: row.client_name,
            paymentCurrency: row.payment_currency,
            amountReceived: row.amount_received ? parseFloat(row.amount_received) : 0,
            changeGiven: row.change_given ? parseFloat(row.change_given) : 0,
            createdAt: row.created_at,
            updatedAt: row.updated_at,
        };
    }
};
exports.SalesService = SalesService;
exports.SalesService = SalesService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], SalesService);
