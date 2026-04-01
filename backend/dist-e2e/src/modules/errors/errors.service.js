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
exports.ErrorsService = void 0;
const common_1 = require("@nestjs/common");
const database_service_1 = require("../../database/database.service");
let ErrorsService = class ErrorsService {
    constructor(db) {
        this.db = db;
    }
    async findAll(limit) {
        const res = await this.db.query('SELECT * FROM error_logs ORDER BY created_at DESC LIMIT $1', [limit || 100]);
        return res.rows.map(this.mapRow);
    }
    async create(dto) {
        const res = await this.db.query(`INSERT INTO error_logs (message, stack, location, user_id, store_id, additional_info) 
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`, [dto.message, dto.stack || null, dto.location || null,
            dto.userId || null, dto.storeId || null, JSON.stringify(dto.additionalInfo || {})]);
        return this.mapRow(res.rows[0]);
    }
    mapRow(row) {
        return {
            id: row.id,
            message: row.message,
            stack: row.stack,
            location: row.location,
            userId: row.user_id,
            storeId: row.store_id,
            additionalInfo: typeof row.additional_info === 'string' ? JSON.parse(row.additional_info) : (row.additional_info || {}),
            createdAt: row.created_at,
        };
    }
};
exports.ErrorsService = ErrorsService;
exports.ErrorsService = ErrorsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], ErrorsService);
