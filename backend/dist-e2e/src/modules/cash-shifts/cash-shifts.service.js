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
exports.CashShiftsService = void 0;
const common_1 = require("@nestjs/common");
const database_service_1 = require("../../database/database.service");
let CashShiftsService = class CashShiftsService {
    constructor(db) {
        this.db = db;
    }
    async openShift(storeId, userId, startingCash) {
        const openRes = await this.db.query("SELECT id FROM cash_shifts WHERE store_id = $1 AND status = 'OPEN'", [storeId]);
        if (openRes.rowCount > 0)
            throw new common_1.BadRequestException('Ya existe un turno de caja abierto en esta tienda');
        const res = await this.db.query(`INSERT INTO cash_shifts (store_id, opened_by, starting_cash, actual_cash, status) 
       VALUES ($1, $2, $3, $4, 'OPEN') RETURNING *`, [storeId, userId, startingCash, startingCash]);
        return this.mapRow(res.rows[0]);
    }
    async closeShift(shiftId, storeId, expectedCash, difference, userId) {
        const res = await this.db.query(`UPDATE cash_shifts 
       SET closed_by = $1, closed_at = NOW(), expected_cash = $2, difference = $3, status = 'CLOSED' 
       WHERE id = $4 AND store_id = $5 AND status = 'OPEN' RETURNING *`, [userId, expectedCash, difference, shiftId, storeId]);
        if (res.rowCount === 0)
            throw new common_1.BadRequestException('Turno de caja no válido o ya cerrado');
        return this.mapRow(res.rows[0]);
    }
    async getActiveShift(storeId) {
        const res = await this.db.query("SELECT * FROM cash_shifts WHERE store_id = $1 AND status = 'OPEN' ORDER BY opened_at DESC LIMIT 1", [storeId]);
        return res.rowCount > 0 ? this.mapRow(res.rows[0]) : null;
    }
    async findAll(storeId, status, cashierId) {
        let sql = 'SELECT * FROM cash_shifts WHERE store_id = $1';
        const params = [storeId];
        if (status) {
            sql += ` AND status = $${params.push(status.toUpperCase())}`;
        }
        if (cashierId) {
            sql += ` AND opened_by = $${params.push(cashierId)}`;
        }
        sql += ' ORDER BY opened_at DESC LIMIT 50';
        const res = await this.db.query(sql, params);
        return res.rows.map(this.mapRow);
    }
    async findOne(id) {
        const res = await this.db.query('SELECT * FROM cash_shifts WHERE id = $1', [id]);
        if (res.rowCount === 0)
            return null;
        return this.mapRow(res.rows[0]);
    }
    async getShiftStats(shiftId) {
        const salesRes = await this.db.query(`SELECT payment_method, SUM(total) as total, COUNT(*) as count
       FROM sales 
       WHERE cash_shift_id = $1 
       GROUP BY payment_method`, [shiftId]);
        const stats = {
            cashSales: 0,
            cardSales: 0,
            totalSales: 0,
            salesCount: 0,
        };
        salesRes.rows.forEach((row) => {
            const val = parseFloat(row.total);
            const count = parseInt(row.count);
            if (row.payment_method === 'CASH')
                stats.cashSales += val;
            if (row.payment_method === 'CARD')
                stats.cardSales += val;
            stats.totalSales += val;
            stats.salesCount += count;
        });
        return stats;
    }
    mapRow(row) {
        return {
            id: row.id,
            storeId: row.store_id,
            openedBy: row.opened_by,
            closedBy: row.closed_by,
            openedAt: row.opened_at,
            closedAt: row.closed_at,
            startingCash: parseFloat(row.starting_cash || 0),
            actualCash: parseFloat(row.actual_cash || 0),
            expectedCash: row.expected_cash ? parseFloat(row.expected_cash) : null,
            difference: row.difference ? parseFloat(row.difference) : null,
            status: row.status,
        };
    }
};
exports.CashShiftsService = CashShiftsService;
exports.CashShiftsService = CashShiftsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], CashShiftsService);
