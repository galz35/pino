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
exports.AccountsReceivableService = void 0;
const common_1 = require("@nestjs/common");
const database_service_1 = require("../../database/database.service");
let AccountsReceivableService = class AccountsReceivableService {
    constructor(db) {
        this.db = db;
    }
    async findAll(storeId, pending) {
        let sql = `SELECT ar.*, c.name as client_name 
               FROM accounts_receivable ar 
               LEFT JOIN clients c ON ar.client_id = c.id 
               WHERE ar.store_id = $1`;
        const params = [storeId];
        if (pending) {
            sql += ' AND ar.remaining_amount > 0';
        }
        sql += ' ORDER BY ar.created_at DESC';
        const res = await this.db.query(sql, params);
        return res.rows.map(this.mapRow);
    }
    async findOne(id) {
        const res = await this.db.query(`SELECT ar.*, c.name as client_name FROM accounts_receivable ar 
       LEFT JOIN clients c ON ar.client_id = c.id WHERE ar.id = $1`, [id]);
        if (res.rowCount === 0)
            throw new common_1.NotFoundException('Cuenta no encontrada');
        return this.mapRow(res.rows[0]);
    }
    async create(dto) {
        const res = await this.db.query(`INSERT INTO accounts_receivable (store_id, client_id, order_id, total_amount, remaining_amount, description) 
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`, [dto.storeId, dto.clientId, dto.orderId || null, dto.totalAmount, dto.totalAmount, dto.description || null]);
        return this.mapRow(res.rows[0]);
    }
    async addPayment(accountId, dto) {
        return await this.db.withTransaction(async (client) => {
            const accRes = await client.query('SELECT * FROM accounts_receivable WHERE id = $1 FOR UPDATE', [accountId]);
            if (accRes.rowCount === 0)
                throw new common_1.NotFoundException('Cuenta no encontrada');
            const account = accRes.rows[0];
            const newRemaining = parseFloat(account.remaining_amount) - dto.amount;
            await client.query('UPDATE accounts_receivable SET remaining_amount = $1, status = $2, updated_at = NOW() WHERE id = $3', [Math.max(0, newRemaining), newRemaining <= 0 ? 'PAID' : 'PARTIAL', accountId]);
            await client.query(`INSERT INTO account_payments (account_id, amount, payment_method, notes, collected_by) 
         VALUES ($1, $2, $3, $4, $5)`, [accountId, dto.amount, dto.paymentMethod || 'CASH', dto.notes || null, dto.collectedBy || null]);
            return { success: true, remainingAmount: Math.max(0, newRemaining) };
        });
    }
    mapRow(row) {
        return {
            id: row.id,
            storeId: row.store_id,
            clientId: row.client_id,
            clientName: row.client_name,
            orderId: row.order_id,
            totalAmount: parseFloat(row.total_amount || 0),
            remainingAmount: parseFloat(row.remaining_amount || 0),
            description: row.description,
            status: row.status,
            createdAt: row.created_at,
            updatedAt: row.updated_at,
        };
    }
};
exports.AccountsReceivableService = AccountsReceivableService;
exports.AccountsReceivableService = AccountsReceivableService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], AccountsReceivableService);
