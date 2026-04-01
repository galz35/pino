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
exports.StoresService = void 0;
const common_1 = require("@nestjs/common");
const database_service_1 = require("../../database/database.service");
let StoresService = class StoresService {
    constructor(db) {
        this.db = db;
    }
    async create(dto) {
        const res = await this.db.query(`INSERT INTO stores (chain_id, name, address, phone) 
       VALUES ($1, $2, $3, $4) RETURNING *`, [dto.chainId, dto.name, dto.address, dto.phone]);
        return this.mapRow(res.rows[0]);
    }
    async findAll(chainId) {
        let query = 'SELECT * FROM stores WHERE is_active = true';
        const params = [];
        if (chainId) {
            query += ' AND chain_id = $1';
            params.push(chainId);
        }
        query += ' ORDER BY name ASC';
        const res = await this.db.query(query, params);
        return res.rows.map(this.mapRow);
    }
    async findOne(id) {
        const res = await this.db.query('SELECT * FROM stores WHERE id = $1', [id]);
        if (res.rowCount === 0)
            throw new common_1.NotFoundException('Tienda no encontrada');
        return this.mapRow(res.rows[0]);
    }
    async update(id, dto) {
        const fieldMap = {
            name: 'name',
            address: 'address',
            phone: 'phone',
            chainId: 'chain_id',
            isActive: 'is_active',
        };
        const sets = [];
        const params = [];
        let idx = 1;
        for (const [camel, snake] of Object.entries(fieldMap)) {
            if (dto[camel] !== undefined) {
                sets.push(`${snake} = $${idx++}`);
                params.push(dto[camel]);
            }
        }
        if (sets.length === 0)
            return this.findOne(id);
        sets.push('updated_at = NOW()');
        params.push(id);
        await this.db.query(`UPDATE stores SET ${sets.join(', ')} WHERE id = $${idx}`, params);
        return this.findOne(id);
    }
    async updateSettings(id, settings) {
        await this.db.query(`UPDATE stores SET settings = settings || $1::jsonb, updated_at = NOW() WHERE id = $2`, [JSON.stringify(settings), id]);
        return this.findOne(id);
    }
    async remove(id) {
        await this.db.query('UPDATE stores SET is_active = false, updated_at = NOW() WHERE id = $1', [id]);
        return this.findOne(id);
    }
    mapRow(row) {
        return {
            id: row.id,
            chainId: row.chain_id,
            name: row.name,
            address: row.address,
            phone: row.phone,
            settings: row.settings || {},
            isActive: row.is_active,
            createdAt: row.created_at,
            updatedAt: row.updated_at,
        };
    }
};
exports.StoresService = StoresService;
exports.StoresService = StoresService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], StoresService);
