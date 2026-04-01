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
exports.DepartmentsService = void 0;
const common_1 = require("@nestjs/common");
const database_service_1 = require("../../database/database.service");
let DepartmentsService = class DepartmentsService {
    constructor(db) {
        this.db = db;
    }
    async create(dto) {
        const res = await this.db.query(`INSERT INTO departments (store_id, name, description) 
       VALUES ($1, $2, $3) RETURNING *`, [dto.storeId, dto.name, dto.description]);
        return res.rows[0];
    }
    async findAll(storeId, type) {
        let sql = 'SELECT * FROM departments WHERE store_id = $1';
        const params = [storeId];
        if (type === 'sub') {
            sql += ` AND parent_id IS NOT NULL`;
        }
        else if (type === 'main') {
            sql += ` AND parent_id IS NULL`;
        }
        sql += ' ORDER BY name ASC';
        const res = await this.db.query(sql, params);
        return res.rows;
    }
    async findOne(id) {
        const res = await this.db.query('SELECT * FROM departments WHERE id = $1', [id]);
        if (res.rowCount === 0)
            throw new common_1.NotFoundException('Departamento no encontrado');
        return res.rows[0];
    }
    async remove(id) {
        await this.db.query('UPDATE departments SET is_active = false WHERE id = $1', [id]);
        return { success: true };
    }
    async update(id, dto) {
        const res = await this.db.query('UPDATE departments SET name = $1 WHERE id = $2 RETURNING *', [dto.name, id]);
        if (res.rowCount === 0)
            throw new common_1.NotFoundException('Departamento no encontrado');
        return res.rows[0];
    }
};
exports.DepartmentsService = DepartmentsService;
exports.DepartmentsService = DepartmentsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], DepartmentsService);
