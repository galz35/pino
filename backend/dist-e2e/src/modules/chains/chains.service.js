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
exports.ChainsService = void 0;
const common_1 = require("@nestjs/common");
const database_service_1 = require("../../database/database.service");
let ChainsService = class ChainsService {
    constructor(db) {
        this.db = db;
    }
    async create(dto) {
        const res = await this.db.query(`INSERT INTO chains (name, logo_url, owner_name, owner_email) 
       VALUES ($1, $2, $3, $4) RETURNING *`, [dto.name, dto.logoUrl || null, dto.ownerName || null, dto.ownerEmail || null]);
        return this.mapRow(res.rows[0]);
    }
    async findAll() {
        const res = await this.db.query("SELECT * FROM chains WHERE status = 'active' ORDER BY name ASC");
        return res.rows.map(this.mapRow);
    }
    async findOne(id) {
        const res = await this.db.query('SELECT * FROM chains WHERE id = $1', [id]);
        if (res.rowCount === 0)
            throw new common_1.NotFoundException('Cadena no encontrada');
        const chain = this.mapRow(res.rows[0]);
        // Fetch stores for this chain
        const storesRes = await this.db.query('SELECT * FROM stores WHERE chain_id = $1 AND is_active = true ORDER BY name ASC', [id]);
        chain.stores = storesRes.rows.map((s) => ({
            id: s.id,
            name: s.name,
            address: s.address,
            phone: s.phone,
            chainId: s.chain_id,
        }));
        return chain;
    }
    async update(id, dto) {
        const fieldMap = {
            name: 'name',
            logoUrl: 'logo_url',
            ownerName: 'owner_name',
            ownerEmail: 'owner_email',
            status: 'status',
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
        await this.db.query(`UPDATE chains SET ${sets.join(', ')} WHERE id = $${idx}`, params);
        return this.findOne(id);
    }
    async remove(id) {
        await this.db.query("UPDATE chains SET status = 'inactive', updated_at = NOW() WHERE id = $1", [id]);
        return this.findOne(id);
    }
    mapRow(row) {
        return {
            id: row.id,
            name: row.name,
            logoUrl: row.logo_url,
            ownerName: row.owner_name,
            ownerEmail: row.owner_email,
            status: row.status,
            createdAt: row.created_at,
            updatedAt: row.updated_at,
        };
    }
};
exports.ChainsService = ChainsService;
exports.ChainsService = ChainsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], ChainsService);
