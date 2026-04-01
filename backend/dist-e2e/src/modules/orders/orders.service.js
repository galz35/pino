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
exports.OrdersService = void 0;
const common_1 = require("@nestjs/common");
const database_service_1 = require("../../database/database.service");
let OrdersService = class OrdersService {
    constructor(db) {
        this.db = db;
    }
    async create(dto) {
        return this.db.withTransaction(async (client) => {
            const total = dto.items.reduce((sum, i) => sum + i.quantity * i.unitPrice, 0);
            const res = await client.query(`INSERT INTO orders (store_id, client_id, client_name, vendor_id, sales_manager_name, total, notes, status)
         VALUES ($1, $2, $3, $4, $5, $6, $7, 'PENDING') RETURNING *`, [dto.storeId, dto.clientId || null, dto.clientName || null, dto.vendorId || null, dto.salesManagerName || null, total, dto.notes || null]);
            const order = res.rows[0];
            for (const item of dto.items) {
                await client.query(`INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal)
           VALUES ($1, $2, $3, $4, $5)`, [order.id, item.productId, item.quantity, item.unitPrice, item.quantity * item.unitPrice]);
            }
            return this.mapRow(order);
        });
    }
    async findAll(filters) {
        let sql = 'SELECT * FROM orders WHERE 1=1';
        const params = [];
        let idx = 1;
        if (filters.storeId) {
            sql += ` AND store_id = $${idx++}`;
            params.push(filters.storeId);
        }
        if (filters.status) {
            sql += ` AND status = $${idx++}`;
            params.push(filters.status.toUpperCase());
        }
        if (filters.vendorId) {
            sql += ` AND vendor_id = $${idx++}`;
            params.push(filters.vendorId);
        }
        if (filters.fromDate) {
            sql += ` AND created_at >= $${idx++}`;
            params.push(new Date(filters.fromDate));
        }
        if (filters.toDate) {
            sql += ` AND created_at <= $${idx++}`;
            params.push(new Date(filters.toDate));
        }
        sql += ' ORDER BY created_at DESC';
        const res = await this.db.query(sql, params);
        return res.rows.map(this.mapRow);
    }
    async findOne(id) {
        var _a;
        const res = await this.db.query('SELECT * FROM orders WHERE id = $1', [id]);
        if (((_a = res.rowCount) !== null && _a !== void 0 ? _a : 0) === 0)
            throw new common_1.NotFoundException('Pedido no encontrado');
        const order = this.mapRow(res.rows[0]);
        const itemsRes = await this.db.query(`SELECT oi.*, p.description as product_name, p.barcode
       FROM order_items oi
       LEFT JOIN products p ON p.id = oi.product_id
       WHERE oi.order_id = $1`, [id]);
        order.items = itemsRes.rows.map((r) => ({
            id: r.id,
            productId: r.product_id,
            productName: r.product_name || 'N/A',
            barcode: r.barcode,
            quantity: r.quantity,
            unitPrice: parseFloat(r.unit_price),
            subtotal: parseFloat(r.subtotal),
        }));
        return order;
    }
    async updateStatus(id, status, updatedBy) {
        var _a;
        const res = await this.db.query(`UPDATE orders SET status = $1, updated_by = $2, updated_at = NOW() WHERE id = $3 RETURNING *`, [status.toUpperCase(), updatedBy || null, id]);
        if (((_a = res.rowCount) !== null && _a !== void 0 ? _a : 0) === 0)
            throw new common_1.NotFoundException('Pedido no encontrado');
        return this.mapRow(res.rows[0]);
    }
    mapRow(row) {
        return {
            id: row.id,
            storeId: row.store_id,
            clientId: row.client_id,
            clientName: row.client_name,
            vendorId: row.vendor_id,
            salesManagerName: row.sales_manager_name || 'N/A',
            total: parseFloat(row.total),
            status: row.status,
            notes: row.notes,
            createdAt: row.created_at,
            updatedAt: row.updated_at,
        };
    }
};
exports.OrdersService = OrdersService;
exports.OrdersService = OrdersService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], OrdersService);
