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
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const jwt_1 = require("@nestjs/jwt");
const bcrypt = require("bcrypt");
const database_service_1 = require("../../database/database.service");
let AuthService = class AuthService {
    constructor(db, jwtService) {
        this.db = db;
        this.jwtService = jwtService;
    }
    async register(dto) {
        // Usamos el bloque transaccional del módulo pg puro
        return await this.db.withTransaction(async (client) => {
            var _a, _b, _c;
            // 1. Verificar si existe
            const existing = await client.query('SELECT id FROM users WHERE email = $1', [dto.email]);
            if (((_a = existing.rowCount) !== null && _a !== void 0 ? _a : 0) > 0)
                throw new common_1.ConflictException('Email ya registrado');
            // 2. Hash e Insertar usuario
            const passwordHash = await bcrypt.hash(dto.password, 10);
            const resUser = await client.query(`INSERT INTO users (email, password_hash, name, role) 
         VALUES ($1, $2, $3, $4) RETURNING *`, [dto.email, passwordHash, dto.name, dto.role]);
            const savedUser = resUser.rows[0];
            // 3. Insertar tiendas asignadas
            if ((_b = dto.storeIds) === null || _b === void 0 ? void 0 : _b.length) {
                for (const storeId of dto.storeIds) {
                    await client.query('INSERT INTO user_stores (user_id, store_id) VALUES ($1, $2)', [savedUser.id, storeId]);
                }
            }
            savedUser.userStores = ((_c = dto.storeIds) === null || _c === void 0 ? void 0 : _c.map(storeId => ({ storeId }))) || [];
            return this.generateTokens(client, savedUser);
        });
    }
    async login(email, password) {
        var _a;
        const resUser = await this.db.query('SELECT * FROM users WHERE email = $1 AND is_active = true', [email]);
        if (((_a = resUser.rowCount) !== null && _a !== void 0 ? _a : 0) === 0)
            throw new common_1.UnauthorizedException('Credenciales inválidas');
        const user = resUser.rows[0];
        const isMatch = await bcrypt.compare(password, user.password_hash);
        if (!isMatch)
            throw new common_1.UnauthorizedException('Credenciales inválidas');
        // Obtener sus tiendas
        const resStores = await this.db.query('SELECT store_id FROM user_stores WHERE user_id = $1', [user.id]);
        user.userStores = resStores.rows.map(r => ({ storeId: r.store_id }));
        // Reutilizamos el pool principal para generar tokens
        const client = await this.db.getClient();
        try {
            return await this.generateTokens(client, user);
        }
        finally {
            client.release();
        }
    }
    async refreshToken(userId) {
        const resUser = await this.db.query('SELECT * FROM users WHERE id = $1 AND is_active = true', [userId]);
        if (resUser.rowCount === 0)
            throw new common_1.UnauthorizedException('Usuario no encontrado');
        const user = resUser.rows[0];
        const resStores = await this.db.query('SELECT store_id FROM user_stores WHERE user_id = $1', [user.id]);
        user.userStores = resStores.rows.map(r => ({ storeId: r.store_id }));
        const client = await this.db.getClient();
        try {
            return await this.generateTokens(client, user);
        }
        finally {
            client.release();
        }
    }
    async getProfile(userId) {
        const resUser = await this.db.query('SELECT * FROM users WHERE id = $1', [userId]);
        if (resUser.rowCount === 0)
            throw new common_1.UnauthorizedException('Usuario no encontrado');
        const user = resUser.rows[0];
        const resStores = await this.db.query('SELECT store_id FROM user_stores WHERE user_id = $1', [user.id]);
        const { password_hash, refresh_token, ...profile } = user;
        return {
            ...profile,
            storeIds: resStores.rows.map(r => r.store_id) || [],
        };
    }
    async generateTokens(client, user) {
        var _a;
        const storeIds = ((_a = user.userStores) === null || _a === void 0 ? void 0 : _a.map((us) => us.storeId)) || [];
        const payload = {
            sub: user.id,
            email: user.email,
            role: user.role,
            storeIds,
        };
        const accessToken = this.jwtService.sign(payload);
        const refreshTokenValue = this.jwtService.sign(payload, { expiresIn: '7d' });
        // Store refresh token en la BD
        await client.query('UPDATE users SET refresh_token = $1 WHERE id = $2', [refreshTokenValue, user.id]);
        return {
            accessToken,
            access_token: accessToken,
            refreshToken: refreshTokenValue,
            refresh_token: refreshTokenValue,
            user: {
                id: user.id,
                email: user.email,
                name: user.name,
                role: user.role,
                storeIds,
            },
        };
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService,
        jwt_1.JwtService])
], AuthService);
