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
exports.InvoicesService = void 0;
const common_1 = require("@nestjs/common");
const database_service_1 = require("../../database/database.service");
let InvoicesService = class InvoicesService {
    constructor(db) {
        this.db = db;
    }
    async create(dto) {
        return this.db.withTransaction(async (client) => {
            // 1. Create invoice
            const invoiceRes = await client.query(`INSERT INTO invoices (store_id, supplier_id, invoice_number, payment_type, due_date, total, status, cashier_name)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *`, [
                dto.storeId,
                dto.supplierId,
                dto.invoiceNumber,
                dto.paymentType,
                dto.dueDate ? new Date(dto.dueDate) : null,
                dto.total,
                dto.status,
                dto.cashierName,
            ]);
            const invoice = invoiceRes.rows[0];
            // 2. Process each item: create invoice_item, update stock, log movement
            for (const item of dto.items) {
                const lineSubtotal = item.quantity * item.unitPrice;
                // Find or create product
                let productId = item.productId || null;
                let currentStock = 0;
                if (!productId) {
                    // Try to find by description
                    const existingProduct = await client.query(`SELECT id, current_stock FROM products WHERE store_id = $1 AND description = $2 LIMIT 1`, [dto.storeId, item.description]);
                    if (existingProduct.rowCount > 0) {
                        productId = existingProduct.rows[0].id;
                        currentStock = existingProduct.rows[0].current_stock || 0;
                    }
                    else {
                        // Create new product
                        const newProduct = await client.query(`INSERT INTO products (store_id, description, sale_price, cost_price, current_stock, uses_inventory, department_id)
               VALUES ($1, $2, $3, $4, $5, true, NULL) RETURNING id`, [dto.storeId, item.description, item.unitPrice * 1.3, item.unitPrice, item.quantity]);
                        productId = newProduct.rows[0].id;
                        // For new products, movement will show had=0, has=quantity
                    }
                }
                else {
                    // Get current stock
                    const prodRes = await client.query('SELECT current_stock FROM products WHERE id = $1 FOR UPDATE', [productId]);
                    if (prodRes.rowCount > 0) {
                        currentStock = prodRes.rows[0].current_stock || 0;
                    }
                }
                // Insert invoice item
                await client.query(`INSERT INTO invoice_items (invoice_id, product_id, description, quantity, unit_price, subtotal)
           VALUES ($1, $2, $3, $4, $5, $6)`, [invoice.id, productId, item.description, item.quantity, item.unitPrice, lineSubtotal]);
                // Update product stock (only for existing products, new ones already have the stock set)
                if (currentStock > 0 || item.productId) {
                    const newStock = currentStock + item.quantity;
                    await client.query('UPDATE products SET current_stock = $1 WHERE id = $2', [newStock, productId]);
                }
                // Log inventory movement
                const finalStock = currentStock + item.quantity;
                await client.query(`INSERT INTO movements (store_id, product_id, type, quantity, balance, reference)
           VALUES ($1, $2, 'IN', $3, $4, $5)`, [
                    dto.storeId,
                    productId,
                    item.quantity,
                    finalStock,
                    `Factura Proveedor #${dto.invoiceNumber}`,
                ]);
            }
            return this.mapRow(invoice);
        });
    }
    async findAll(storeId, supplierId) {
        let sql = 'SELECT i.*, s.name as supplier_name FROM invoices i LEFT JOIN suppliers s ON i.supplier_id = s.id WHERE 1=1';
        const params = [];
        if (storeId) {
            params.push(storeId);
            sql += ` AND i.store_id = $${params.length}`;
        }
        if (supplierId) {
            params.push(supplierId);
            sql += ` AND i.supplier_id = $${params.length}`;
        }
        sql += ' ORDER BY i.created_at DESC';
        const res = await this.db.query(sql, params);
        return res.rows.map(this.mapRow);
    }
    async findOne(id) {
        const res = await this.db.query('SELECT i.*, s.name as supplier_name FROM invoices i LEFT JOIN suppliers s ON i.supplier_id = s.id WHERE i.id = $1', [id]);
        if (res.rowCount === 0)
            throw new common_1.NotFoundException('Factura no encontrada');
        const invoice = this.mapRow(res.rows[0]);
        const itemsRes = await this.db.query(`SELECT ii.*, p.description as product_description
       FROM invoice_items ii
       LEFT JOIN products p ON ii.product_id = p.id
       WHERE ii.invoice_id = $1`, [id]);
        invoice.items = itemsRes.rows.map((r) => ({
            id: r.id,
            productId: r.product_id,
            description: r.description,
            quantity: parseFloat(r.quantity),
            unitPrice: parseFloat(r.unit_price),
            subtotal: parseFloat(r.subtotal),
        }));
        return invoice;
    }
    async update(id, dto) {
        if (dto.status) {
            await this.db.query('UPDATE invoices SET status = $1, updated_at = NOW() WHERE id = $2', [dto.status, id]);
        }
        return this.findOne(id);
    }
    async remove(id) {
        await this.db.query('DELETE FROM invoices WHERE id = $1', [id]);
        return { success: true };
    }
    mapRow(row) {
        return {
            id: row.id,
            storeId: row.store_id,
            supplierId: row.supplier_id,
            supplierName: row.supplier_name || '',
            invoiceNumber: row.invoice_number,
            paymentType: row.payment_type,
            dueDate: row.due_date,
            total: parseFloat(row.total),
            status: row.status,
            cashierName: row.cashier_name,
            createdAt: row.created_at,
            updatedAt: row.updated_at,
        };
    }
};
exports.InvoicesService = InvoicesService;
exports.InvoicesService = InvoicesService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], InvoicesService);
