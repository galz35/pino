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
exports.PendingOrdersService = void 0;
const common_1 = require("@nestjs/common");
const database_service_1 = require("../../database/database.service");
let PendingOrdersService = class PendingOrdersService {
    constructor(db) {
        this.db = db;
    }
    async findAll(storeId, status) {
        let sql = `SELECT po.*, c.name as client_name 
               FROM pending_orders po 
               LEFT JOIN clients c ON po.client_id = c.id 
               WHERE po.store_id = $1`;
        const params = [storeId];
        if (status)
            sql += ` AND po.status = $${params.push(status)}`;
        sql += ' ORDER BY po.created_at DESC';
        const res = await this.db.query(sql, params);
        return res.rows.map(this.mapRow);
    }
    async create(dto) {
        const res = await this.db.query(`INSERT INTO pending_orders (store_id, client_id, client_name, items, total, notes, payment_method, status) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, 'Pendiente') RETURNING *`, [dto.storeId, dto.clientId || null, dto.clientName || null,
            JSON.stringify(dto.items || []), dto.total || 0, dto.notes || null, dto.paymentMethod || 'Efectivo']);
        return this.mapRow(res.rows[0]);
    }
    async dispatch(dto) {
        return await this.db.withTransaction(async (client) => {
            for (const orderId of dto.orderIds) {
                await client.query(`UPDATE pending_orders SET status = 'Despachado', dispatched_by = $1, dispatched_at = NOW(), updated_at = NOW() WHERE id = $2`, [dto.dispatchedBy, orderId]);
            }
            return { success: true, dispatched: dto.orderIds.length };
        });
    }
    async updateStatus(id, status) {
        await this.db.query('UPDATE pending_orders SET status = $1, updated_at = NOW() WHERE id = $2', [status, id]);
        return { success: true };
    }
    mapRow(row) {
        return {
            id: row.id,
            storeId: row.store_id,
            clientId: row.client_id,
            clientName: row.client_name,
            items: typeof row.items === 'string' ? JSON.parse(row.items) : (row.items || []),
            total: parseFloat(row.total || 0),
            notes: row.notes,
            paymentMethod: row.payment_method,
            status: row.status,
            dispatchedBy: row.dispatched_by,
            dispatchedAt: row.dispatched_at,
            createdAt: row.created_at,
            updatedAt: row.updated_at,
        };
    }
};
exports.PendingOrdersService = PendingOrdersService;
exports.PendingOrdersService = PendingOrdersService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], PendingOrdersService);
