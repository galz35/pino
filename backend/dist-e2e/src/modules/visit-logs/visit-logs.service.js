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
exports.VisitLogsService = void 0;
const common_1 = require("@nestjs/common");
const database_service_1 = require("../../database/database.service");
let VisitLogsService = class VisitLogsService {
    constructor(db) {
        this.db = db;
    }
    async findAll(storeId, days) {
        const daysNum = days || 30;
        const res = await this.db.query(`SELECT * FROM visit_logs 
       WHERE store_id = $1 AND created_at >= NOW() - INTERVAL '1 day' * $2 
       ORDER BY created_at DESC`, [storeId, daysNum]);
        return res.rows.map(this.mapRow);
    }
    async create(dto) {
        const res = await this.db.query(`INSERT INTO visit_logs (store_id, vendor_id, client_id, notes, latitude, longitude) 
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`, [dto.storeId, dto.vendorId, dto.clientId, dto.notes || null, dto.latitude || null, dto.longitude || null]);
        return this.mapRow(res.rows[0]);
    }
    mapRow(row) {
        return {
            id: row.id,
            storeId: row.store_id,
            vendorId: row.vendor_id,
            clientId: row.client_id,
            notes: row.notes,
            latitude: row.latitude,
            longitude: row.longitude,
            createdAt: row.created_at,
        };
    }
};
exports.VisitLogsService = VisitLogsService;
exports.VisitLogsService = VisitLogsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], VisitLogsService);
