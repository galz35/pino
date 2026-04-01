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
exports.RoutesService = void 0;
const common_1 = require("@nestjs/common");
const database_service_1 = require("../../database/database.service");
let RoutesService = class RoutesService {
    constructor(db) {
        this.db = db;
    }
    async findAll(storeId, vendorId) {
        let sql = 'SELECT * FROM routes WHERE store_id = $1';
        const params = [storeId];
        if (vendorId)
            sql += ` AND vendor_id = $${params.push(vendorId)}`;
        sql += ' ORDER BY created_at DESC';
        const res = await this.db.query(sql, params);
        return res.rows.map(this.mapRow);
    }
    async create(dto) {
        const res = await this.db.query(`INSERT INTO routes (store_id, vendor_id, client_ids, route_date, notes, status) 
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`, [dto.storeId, dto.vendorId, JSON.stringify(dto.clientIds || []),
            dto.date || new Date().toISOString(), dto.notes || null, dto.status || 'pending']);
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
        if (dto.notes !== undefined) {
            sets.push(`notes = $${idx++}`);
            params.push(dto.notes);
        }
        if (sets.length === 0)
            return;
        sets.push('updated_at = NOW()');
        params.push(id);
        await this.db.query(`UPDATE routes SET ${sets.join(', ')} WHERE id = $${idx}`, params);
        return { success: true };
    }
    mapRow(row) {
        return {
            id: row.id,
            storeId: row.store_id,
            vendorId: row.vendor_id,
            clientIds: typeof row.client_ids === 'string' ? JSON.parse(row.client_ids) : (row.client_ids || []),
            routeDate: row.route_date,
            notes: row.notes,
            status: row.status,
            createdAt: row.created_at,
            updatedAt: row.updated_at,
        };
    }
};
exports.RoutesService = RoutesService;
exports.RoutesService = RoutesService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], RoutesService);
