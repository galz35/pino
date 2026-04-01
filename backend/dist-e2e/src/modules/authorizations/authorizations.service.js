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
exports.AuthorizationsService = void 0;
const common_1 = require("@nestjs/common");
const database_service_1 = require("../../database/database.service");
let AuthorizationsService = class AuthorizationsService {
    constructor(db) {
        this.db = db;
    }
    async create(dto) {
        const res = await this.db.query(`INSERT INTO authorizations (store_id, requester_id, type, details, status)
       VALUES ($1, $2, $3, $4, $5) RETURNING *`, [dto.storeId, dto.requesterId, dto.type, JSON.stringify(dto.details), 'PENDING']);
        return res.rows[0];
    }
    async findAll(storeId, status) {
        let q = 'SELECT * FROM authorizations WHERE store_id = $1';
        const params = [storeId];
        if (status) {
            q += ' AND status = $2';
            params.push(status);
        }
        q += ' ORDER BY created_at DESC';
        const res = await this.db.query(q, params);
        return res.rows;
    }
    async updateStatus(id, status) {
        const res = await this.db.query('UPDATE authorizations SET status = $1 WHERE id = $2 RETURNING *', [status, id]);
        if (res.rowCount === 0)
            throw new common_1.NotFoundException('Autorización no encontrada');
        return res.rows[0];
    }
};
exports.AuthorizationsService = AuthorizationsService;
exports.AuthorizationsService = AuthorizationsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], AuthorizationsService);
