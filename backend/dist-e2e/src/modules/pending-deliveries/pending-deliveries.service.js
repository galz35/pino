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
exports.PendingDeliveriesService = void 0;
const common_1 = require("@nestjs/common");
const database_service_1 = require("../../database/database.service");
let PendingDeliveriesService = class PendingDeliveriesService {
    constructor(db) {
        this.db = db;
    }
    async findAll(filters) {
        let sql = `SELECT pd.*, c.name as client_name, o.total as order_total
               FROM pending_deliveries pd 
               LEFT JOIN clients c ON pd.client_id = c.id 
               LEFT JOIN orders o ON pd.order_id = o.id 
               WHERE 1=1`;
        const params = [];
        if (filters.storeId)
            sql += ` AND pd.store_id = $${params.push(filters.storeId)}`;
        if (filters.status)
            sql += ` AND pd.status = $${params.push(filters.status)}`;
        if (filters.ruteroId)
            sql += ` AND pd.rutero_id = $${params.push(filters.ruteroId)}`;
        if (filters.unassigned)
            sql += ' AND pd.rutero_id IS NULL';
        sql += ' ORDER BY pd.created_at DESC';
        const res = await this.db.query(sql, params);
        return res.rows.map(this.mapRow);
    }
    async create(dto) {
        const res = await this.db.query(`INSERT INTO pending_deliveries (store_id, order_id, client_id, address, notes, status) 
       VALUES ($1, $2, $3, $4, $5, 'Pendiente') RETURNING *`, [dto.storeId, dto.orderId, dto.clientId || null, dto.address || null, dto.notes || null]);
        return this.mapRow(res.rows[0]);
    }
    async update(id, dto) {
        const sets = [];
        const params = [];
        let idx = 1;
        if (dto.status) {
            sets.push(`status = $${idx++}`);
            params.push(dto.status);
        }
        if (dto.ruteroId) {
            sets.push(`rutero_id = $${idx++}`);
            params.push(dto.ruteroId);
        }
        if (sets.length === 0)
            return;
        sets.push('updated_at = NOW()');
        params.push(id);
        await this.db.query(`UPDATE pending_deliveries SET ${sets.join(', ')} WHERE id = $${idx}`, params);
        return { success: true };
    }
    async assignRoute(dto) {
        return await this.db.withTransaction(async (client) => {
            for (const deliveryId of dto.deliveryIds) {
                await client.query(`UPDATE pending_deliveries SET rutero_id = $1, status = 'Asignado', route_date = $2, updated_at = NOW() WHERE id = $3`, [dto.ruteroId, dto.date || new Date().toISOString(), deliveryId]);
            }
            return { success: true, assigned: dto.deliveryIds.length };
        });
    }
    mapRow(row) {
        return {
            id: row.id,
            storeId: row.store_id,
            orderId: row.order_id,
            clientId: row.client_id,
            clientName: row.client_name,
            orderTotal: row.order_total ? parseFloat(row.order_total) : null,
            ruteroId: row.rutero_id,
            address: row.address,
            notes: row.notes,
            status: row.status,
            routeDate: row.route_date,
            createdAt: row.created_at,
            updatedAt: row.updated_at,
        };
    }
};
exports.PendingDeliveriesService = PendingDeliveriesService;
exports.PendingDeliveriesService = PendingDeliveriesService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], PendingDeliveriesService);
