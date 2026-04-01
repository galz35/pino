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
exports.ZonesService = void 0;
const common_1 = require("@nestjs/common");
const database_service_1 = require("../../database/database.service");
let ZonesService = class ZonesService {
    constructor(db) {
        this.db = db;
    }
    // ─── ZONES ───────────────────────────────────────────────
    async findAllZones(storeId) {
        let sql = 'SELECT * FROM zones';
        const params = [];
        if (storeId) {
            sql += ' WHERE store_id = $1';
            params.push(storeId);
        }
        sql += ' ORDER BY name ASC';
        const res = await this.db.query(sql, params);
        return res.rows.map(this.mapZone);
    }
    async createZone(dto) {
        const res = await this.db.query(`INSERT INTO zones (name, store_id, description) VALUES ($1, $2, $3) RETURNING *`, [dto.name, dto.storeId || null, dto.description || null]);
        return this.mapZone(res.rows[0]);
    }
    async updateZone(id, dto) {
        var _a;
        const sets = [];
        const params = [];
        let idx = 1;
        if (dto.name) {
            sets.push(`name = $${idx++}`);
            params.push(dto.name);
        }
        if (dto.description !== undefined) {
            sets.push(`description = $${idx++}`);
            params.push(dto.description);
        }
        if (sets.length === 0)
            throw new common_1.NotFoundException('Nada que actualizar');
        sets.push(`updated_at = NOW()`);
        params.push(id);
        const res = await this.db.query(`UPDATE zones SET ${sets.join(', ')} WHERE id = $${idx} RETURNING *`, params);
        if (((_a = res.rowCount) !== null && _a !== void 0 ? _a : 0) === 0)
            throw new common_1.NotFoundException('Zona no encontrada');
        return this.mapZone(res.rows[0]);
    }
    async deleteZone(id) {
        var _a;
        const res = await this.db.query('DELETE FROM zones WHERE id = $1 RETURNING id', [id]);
        if (((_a = res.rowCount) !== null && _a !== void 0 ? _a : 0) === 0)
            throw new common_1.NotFoundException('Zona no encontrada');
        return { deleted: true, id };
    }
    // ─── SUB-ZONES ───────────────────────────────────────────
    async findAllSubZones(zoneId) {
        let sql = 'SELECT sz.*, z.name as zone_name FROM sub_zones sz LEFT JOIN zones z ON z.id = sz.zone_id';
        const params = [];
        if (zoneId) {
            sql += ' WHERE sz.zone_id = $1';
            params.push(zoneId);
        }
        sql += ' ORDER BY sz.name ASC';
        const res = await this.db.query(sql, params);
        return res.rows.map(this.mapSubZone);
    }
    async createSubZone(dto) {
        const res = await this.db.query(`INSERT INTO sub_zones (name, zone_id, description) VALUES ($1, $2, $3) RETURNING *`, [dto.name, dto.zoneId, dto.description || null]);
        return this.mapSubZone(res.rows[0]);
    }
    async updateSubZone(id, dto) {
        var _a;
        const sets = [];
        const params = [];
        let idx = 1;
        if (dto.name) {
            sets.push(`name = $${idx++}`);
            params.push(dto.name);
        }
        if (dto.description !== undefined) {
            sets.push(`description = $${idx++}`);
            params.push(dto.description);
        }
        if (sets.length === 0)
            throw new common_1.NotFoundException('Nada que actualizar');
        sets.push(`updated_at = NOW()`);
        params.push(id);
        const res = await this.db.query(`UPDATE sub_zones SET ${sets.join(', ')} WHERE id = $${idx} RETURNING *`, params);
        if (((_a = res.rowCount) !== null && _a !== void 0 ? _a : 0) === 0)
            throw new common_1.NotFoundException('Sub-zona no encontrada');
        return this.mapSubZone(res.rows[0]);
    }
    async deleteSubZone(id) {
        var _a;
        const res = await this.db.query('DELETE FROM sub_zones WHERE id = $1 RETURNING id', [id]);
        if (((_a = res.rowCount) !== null && _a !== void 0 ? _a : 0) === 0)
            throw new common_1.NotFoundException('Sub-zona no encontrada');
        return { deleted: true, id };
    }
    mapZone(row) {
        return {
            id: row.id,
            name: row.name,
            storeId: row.store_id,
            description: row.description,
            createdAt: row.created_at,
            updatedAt: row.updated_at,
        };
    }
    mapSubZone(row) {
        return {
            id: row.id,
            name: row.name,
            zoneId: row.zone_id,
            zoneName: row.zone_name || null,
            description: row.description,
            createdAt: row.created_at,
            updatedAt: row.updated_at,
        };
    }
};
exports.ZonesService = ZonesService;
exports.ZonesService = ZonesService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], ZonesService);
