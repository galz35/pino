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
exports.ConfigService = void 0;
const common_1 = require("@nestjs/common");
const database_service_1 = require("../../database/database.service");
let ConfigService = class ConfigService {
    constructor(db) {
        this.db = db;
    }
    async getByKey(key) {
        const res = await this.db.query('SELECT * FROM config WHERE key = $1', [key]);
        if (res.rowCount === 0)
            return { key, value: {} };
        return { key: res.rows[0].key, value: res.rows[0].value };
    }
    async upsert(key, value) {
        const res = await this.db.query(`INSERT INTO config (key, value, updated_at) VALUES ($1, $2, NOW())
       ON CONFLICT (key) DO UPDATE SET value = $2, updated_at = NOW()
       RETURNING *`, [key, JSON.stringify(value)]);
        return { key: res.rows[0].key, value: res.rows[0].value };
    }
    async getAll() {
        const res = await this.db.query('SELECT * FROM config ORDER BY key ASC');
        return res.rows.map((r) => ({ key: r.key, value: r.value }));
    }
};
exports.ConfigService = ConfigService;
exports.ConfigService = ConfigService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], ConfigService);
