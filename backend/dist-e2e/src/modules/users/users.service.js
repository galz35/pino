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
exports.UsersService = void 0;
const common_1 = require("@nestjs/common");
const database_service_1 = require("../../database/database.service");
const bcrypt = require("bcrypt");
let UsersService = class UsersService {
    constructor(db) {
        this.db = db;
    }
    async findAll(storeId, role) {
        let sql = 'SELECT DISTINCT u.id, u.email, u.name, u.role, u.is_active, u.created_at FROM users u';
        const params = [];
        const conditions = [];
        if (storeId) {
            sql += ' JOIN user_stores us ON u.id = us.user_id';
            conditions.push(`us.store_id = $${params.push(storeId)}`);
        }
        if (role) {
            conditions.push(`u.role ILIKE $${params.push(role)}`);
        }
        if (conditions.length > 0) {
            sql += ' WHERE ' + conditions.join(' AND ');
        }
        sql += ' ORDER BY u.name ASC';
        const res = await this.db.query(sql, params);
        return res.rows.map(this.mapRow);
    }
    async createUser(dto) {
        return await this.db.withTransaction(async (client) => {
            var _a;
            const existing = await client.query('SELECT id FROM users WHERE email = $1', [dto.email]);
            if (((_a = existing.rowCount) !== null && _a !== void 0 ? _a : 0) > 0)
                throw new common_1.ConflictException('Email ya registrado');
            const passwordHash = await bcrypt.hash(dto.password, 10);
            const resUser = await client.query(`INSERT INTO users (email, password_hash, name, role) VALUES ($1, $2, $3, $4) RETURNING *`, [dto.email, passwordHash, dto.name, dto.role]);
            const user = resUser.rows[0];
            // Assign stores
            const storeIds = dto.storeIds || (dto.storeId ? [dto.storeId] : []);
            for (const sid of storeIds) {
                await client.query('INSERT INTO user_stores (user_id, store_id) VALUES ($1, $2)', [user.id, sid]);
            }
            return this.mapRow(user);
        });
    }
    async findOne(id) {
        const res = await this.db.query('SELECT id, email, name, role, is_active, created_at FROM users WHERE id = $1', [id]);
        if (res.rowCount === 0)
            throw new common_1.NotFoundException('Usuario no encontrado');
        const user = this.mapRow(res.rows[0]);
        // Get assigned stores
        const storesRes = await this.db.query(`SELECT s.id, s.name FROM stores s 
       JOIN user_stores us ON s.id = us.store_id 
       WHERE us.user_id = $1`, [id]);
        user.stores = storesRes.rows;
        user.storeIds = storesRes.rows.map((s) => s.id);
        return user;
    }
    async findByEmail(email) {
        const res = await this.db.query('SELECT * FROM users WHERE email = $1', [email]);
        return res.rowCount > 0 ? res.rows[0] : null;
    }
    async update(id, dto) {
        const fieldMap = {
            name: 'name',
            email: 'email',
            role: 'role',
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
        await this.db.query(`UPDATE users SET ${sets.join(', ')} WHERE id = $${idx}`, params);
        return this.findOne(id);
    }
    async assignToStore(userId, storeId) {
        await this.db.query('INSERT INTO user_stores (user_id, store_id) VALUES ($1, $2) ON CONFLICT DO NOTHING', [userId, storeId]);
        return { success: true };
    }
    async getUserStores(userId) {
        const res = await this.db.query(`SELECT s.* FROM stores s 
       JOIN user_stores us ON s.id = us.store_id 
       WHERE us.user_id = $1 AND s.is_active = true ORDER BY s.name ASC`, [userId]);
        return res.rows.map((s) => ({
            id: s.id,
            name: s.name,
            address: s.address,
            phone: s.phone,
            chainId: s.chain_id,
        }));
    }
    async remove(id) {
        await this.db.query('DELETE FROM user_stores WHERE user_id = $1', [id]);
        const res = await this.db.query('DELETE FROM users WHERE id = $1 RETURNING id', [id]);
        if (res.rowCount === 0)
            throw new common_1.NotFoundException('Usuario no encontrado');
        return { success: true, message: 'Usuario eliminado correctamente' };
    }
    mapRow(row) {
        return {
            id: row.id,
            email: row.email,
            name: row.name,
            role: row.role,
            isActive: row.is_active,
            createdAt: row.created_at,
        };
    }
};
exports.UsersService = UsersService;
exports.UsersService = UsersService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], UsersService);
