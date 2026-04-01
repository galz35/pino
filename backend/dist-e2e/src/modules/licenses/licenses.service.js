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
exports.LicensesService = void 0;
const common_1 = require("@nestjs/common");
const database_service_1 = require("../../database/database.service");
let LicensesService = class LicensesService {
    constructor(db) {
        this.db = db;
    }
    async findAll(storeId) {
        let sql = 'SELECT l.*, s.name as store_name FROM licenses l LEFT JOIN stores s ON s.id = l.store_id';
        const params = [];
        if (storeId) {
            sql += ' WHERE l.store_id = $1';
            params.push(storeId);
        }
        sql += ' ORDER BY l.created_at DESC';
        const res = await this.db.query(sql, params);
        return res.rows.map(this.mapRow);
    }
    async findOne(id) {
        var _a;
        const res = await this.db.query('SELECT l.*, s.name as store_name FROM licenses l LEFT JOIN stores s ON s.id = l.store_id WHERE l.id = $1', [id]);
        if (((_a = res.rowCount) !== null && _a !== void 0 ? _a : 0) === 0)
            throw new common_1.NotFoundException('Licencia no encontrada');
        return this.mapRow(res.rows[0]);
    }
    async create(dto) {
        const key = dto.licenseKey || this.generateKey();
        const res = await this.db.query(`INSERT INTO licenses (store_id, license_key, type, max_users, end_date)
       VALUES ($1, $2, $3, $4, $5) RETURNING *`, [dto.storeId, key, dto.type || 'standard', dto.maxUsers || 5, dto.endDate || null]);
        return this.mapRow(res.rows[0]);
    }
    async update(id, dto) {
        var _a;
        const sets = [];
        const params = [];
        let idx = 1;
        if (dto.status) {
            sets.push(`status = $${idx++}`);
            params.push(dto.status);
        }
        if (dto.type) {
            sets.push(`type = $${idx++}`);
            params.push(dto.type);
        }
        if (dto.maxUsers !== undefined) {
            sets.push(`max_users = $${idx++}`);
            params.push(dto.maxUsers);
        }
        if (dto.endDate !== undefined) {
            sets.push(`end_date = $${idx++}`);
            params.push(dto.endDate || null);
        }
        if (sets.length === 0)
            throw new common_1.NotFoundException('Nada que actualizar');
        sets.push(`updated_at = NOW()`);
        params.push(id);
        const res = await this.db.query(`UPDATE licenses SET ${sets.join(', ')} WHERE id = $${idx} RETURNING *`, params);
        if (((_a = res.rowCount) !== null && _a !== void 0 ? _a : 0) === 0)
            throw new common_1.NotFoundException('Licencia no encontrada');
        return this.mapRow(res.rows[0]);
    }
    async delete(id) {
        var _a;
        const res = await this.db.query('DELETE FROM licenses WHERE id = $1 RETURNING id', [id]);
        if (((_a = res.rowCount) !== null && _a !== void 0 ? _a : 0) === 0)
            throw new common_1.NotFoundException('Licencia no encontrada');
        return { deleted: true, id };
    }
    generateKey() {
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        const segments = 4;
        const segLen = 4;
        const parts = [];
        for (let s = 0; s < segments; s++) {
            let seg = '';
            for (let i = 0; i < segLen; i++) {
                seg += chars.charAt(Math.floor(Math.random() * chars.length));
            }
            parts.push(seg);
        }
        return parts.join('-');
    }
    mapRow(row) {
        return {
            id: row.id,
            storeId: row.store_id,
            storeName: row.store_name || null,
            licenseKey: row.license_key,
            status: row.status,
            type: row.type,
            startDate: row.start_date,
            endDate: row.end_date,
            maxUsers: row.max_users,
            createdAt: row.created_at,
            updatedAt: row.updated_at,
        };
    }
};
exports.LicensesService = LicensesService;
exports.LicensesService = LicensesService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], LicensesService);
