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
exports.InventoryService = void 0;
const common_1 = require("@nestjs/common");
const database_service_1 = require("../../database/database.service");
let InventoryService = class InventoryService {
    constructor(db) {
        this.db = db;
    }
    async adjustStock(dto) {
        return await this.db.withTransaction(async (client) => {
            // 1. Bloquear registro del producto para asegurar transaccion y prevenir dirty reads
            const prodRes = await client.query('SELECT current_stock FROM products WHERE id = $1 AND store_id = $2 FOR UPDATE', [dto.productId, dto.storeId]);
            if (prodRes.rowCount === 0)
                throw new common_1.BadRequestException('Producto no encontrado en esta tienda');
            const currentStock = prodRes.rows[0].current_stock;
            let newStock = currentStock;
            if (dto.type === 'IN') {
                newStock += dto.quantity;
            }
            else {
                newStock -= dto.quantity;
                if (newStock < 0)
                    throw new common_1.BadRequestException('El ajuste resulta en stock negativo (Operación Denegada)');
            }
            // 2. Actualizar balance
            await client.query('UPDATE products SET current_stock = $1 WHERE id = $2', [newStock, dto.productId]);
            // 3. Registrar Movimiento de Kárdex
            const movRes = await client.query(`INSERT INTO movements (store_id, product_id, user_id, type, quantity, balance, reference) 
         VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`, [dto.storeId, dto.productId, dto.userId, dto.type, dto.quantity, newStock, dto.reference]);
            return movRes.rows[0];
        });
    }
    async getKardex(storeId, productId) {
        const res = await this.db.query(`SELECT m.*, u.name as user_name 
       FROM movements m 
       LEFT JOIN users u ON m.user_id = u.id 
       WHERE m.store_id = $1 AND m.product_id = $2 
       ORDER BY m.created_at DESC`, [storeId, productId]);
        return res.rows;
    }
    async getMovements(storeId, date, type) {
        let sql = `
      SELECT m.*, p.description as product_description, u.name as user_name 
      FROM movements m
      LEFT JOIN products p ON m.product_id = p.id
      LEFT JOIN users u ON m.user_id = u.id
      WHERE m.store_id = $1
    `;
        const params = [storeId];
        if (date) {
            sql += ' AND m.created_at::date = $' + (params.push(date));
        }
        if (type && type !== 'all') {
            sql += ' AND m.type = $' + (params.push(type.toUpperCase()));
        }
        sql += ' ORDER BY m.created_at DESC LIMIT 200';
        const res = await this.db.query(sql, params);
        return res.rows.map(row => ({
            id: row.id,
            storeId: row.store_id,
            productId: row.product_id,
            productDescription: row.product_description,
            userId: row.user_id,
            userName: row.user_name,
            type: row.type,
            quantity: parseFloat(row.quantity),
            balance: parseFloat(row.balance),
            reference: row.reference,
            createdAt: row.created_at
        }));
    }
};
exports.InventoryService = InventoryService;
exports.InventoryService = InventoryService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], InventoryService);
