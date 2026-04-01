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
exports.StoreZonesService = void 0;
const common_1 = require("@nestjs/common");
const database_service_1 = require("../../database/database.service");
let StoreZonesService = class StoreZonesService {
    constructor(db) {
        this.db = db;
    }
    async findAll(storeId) {
        const res = await this.db.query('SELECT * FROM store_zones WHERE store_id = $1 ORDER BY name ASC', [storeId]);
        return res.rows.map(this.mapRow);
    }
    async findOne(id) {
        const res = await this.db.query('SELECT * FROM store_zones WHERE id = $1', [id]);
        if (res.rowCount === 0)
            throw new common_1.NotFoundException('Zona no encontrada');
        return this.mapRow(res.rows[0]);
    }
    async create(dto) {
        const res = await this.db.query(`INSERT INTO store_zones (store_id, name, description, color) 
       VALUES ($1, $2, $3, $4) RETURNING *`, [dto.storeId, dto.name, dto.description || null, dto.color || null]);
        return this.mapRow(res.rows[0]);
    }
    async update(id, dto) {
        const sets = [];
        const params = [];
        let idx = 1;
        if (dto.name !== undefined) {
            sets.push(`name = $${idx++}`);
            params.push(dto.name);
        }
        if (dto.description !== undefined) {
            sets.push(`description = $${idx++}`);
            params.push(dto.description);
        }
        if (dto.color !== undefined) {
            sets.push(`color = $${idx++}`);
            params.push(dto.color);
        }
        if (sets.length === 0)
            return this.findOne(id);
        sets.push('updated_at = NOW()');
        params.push(id);
        await this.db.query(`UPDATE store_zones SET ${sets.join(', ')} WHERE id = $${idx}`, params);
        return this.findOne(id);
    }
    async remove(id) {
        await this.db.query('DELETE FROM store_zones WHERE id = $1', [id]);
        return { success: true };
    }
    mapRow(row) {
        return {
            id: row.id,
            storeId: row.store_id,
            name: row.name,
            description: row.description,
            color: row.color,
            createdAt: row.created_at,
            updatedAt: row.updated_at,
        };
    }
};
exports.StoreZonesService = StoreZonesService;
exports.StoreZonesService = StoreZonesService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], StoreZonesService);
