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
exports.SuppliersService = void 0;
const common_1 = require("@nestjs/common");
const database_service_1 = require("../../database/database.service");
let SuppliersService = class SuppliersService {
    constructor(db) {
        this.db = db;
    }
    async create(dto) {
        const res = await this.db.query(`INSERT INTO suppliers (chain_id, name, contact_name, email, phone, address) 
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`, [dto.chainId || dto.storeId, dto.name, dto.contactName, dto.email, dto.phone, dto.address]);
        return this.mapRow(res.rows[0]);
    }
    async findAll(chainId, storeId) {
        let sql = 'SELECT * FROM suppliers WHERE 1=1';
        const params = [];
        if (chainId) {
            params.push(chainId);
            sql += ` AND chain_id = $${params.length}`;
        }
        if (storeId) {
            // If frontend passes storeId, look up chain_id from stores table
            params.push(storeId);
            sql += ` AND chain_id = (SELECT chain_id FROM stores WHERE id = $${params.length})`;
        }
        sql += ' ORDER BY name ASC';
        const res = await this.db.query(sql, params);
        return res.rows.map(this.mapRow);
    }
    async findOne(id) {
        const res = await this.db.query('SELECT * FROM suppliers WHERE id = $1', [id]);
        if (res.rowCount === 0)
            throw new common_1.NotFoundException('Proveedor no encontrado');
        return this.mapRow(res.rows[0]);
    }
    async update(id, dto) {
        const fieldMap = {
            name: 'name',
            contactName: 'contact_name',
            email: 'email',
            phone: 'phone',
            address: 'address',
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
        params.push(id);
        await this.db.query(`UPDATE suppliers SET ${sets.join(', ')} WHERE id = $${idx}`, params);
        return this.findOne(id);
    }
    async remove(id) {
        await this.db.query('DELETE FROM suppliers WHERE id = $1', [id]);
        return { success: true };
    }
    mapRow(row) {
        return {
            id: row.id,
            chainId: row.chain_id,
            name: row.name,
            contactName: row.contact_name,
            email: row.email,
            phone: row.phone,
            address: row.address,
            createdAt: row.created_at,
        };
    }
};
exports.SuppliersService = SuppliersService;
exports.SuppliersService = SuppliersService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], SuppliersService);
