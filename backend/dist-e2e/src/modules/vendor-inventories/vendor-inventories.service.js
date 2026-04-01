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
exports.VendorInventoriesService = void 0;
const common_1 = require("@nestjs/common");
const database_service_1 = require("../../database/database.service");
let VendorInventoriesService = class VendorInventoriesService {
    constructor(db) {
        this.db = db;
    }
    async getInventory(vendorId, productId) {
        const res = await this.db.query('SELECT * FROM vendor_inventories WHERE vendor_id = $1 AND product_id = $2', [vendorId, productId]);
        if (res.rowCount === 0) {
            return { vendorId, productId, assignedQuantity: 0, soldQuantity: 0, currentQuantity: 0 };
        }
        return this.mapRow(res.rows[0]);
    }
    async getVendorProducts(vendorId) {
        const res = await this.db.query(`SELECT vi.*, p.description, p.barcode 
       FROM vendor_inventories vi 
       JOIN products p ON vi.product_id = p.id 
       WHERE vi.vendor_id = $1 AND vi.current_quantity > 0 
       ORDER BY p.description ASC`, [vendorId]);
        return res.rows.map(this.mapRow);
    }
    async processTransaction(dto) {
        return await this.db.withTransaction(async (client) => {
            // Get or create record
            let res = await client.query('SELECT * FROM vendor_inventories WHERE vendor_id = $1 AND product_id = $2 FOR UPDATE', [dto.vendorId, dto.productId]);
            let currentQty = 0;
            if (res.rowCount === 0) {
                await client.query('INSERT INTO vendor_inventories (vendor_id, product_id, store_id, assigned_quantity, sold_quantity, current_quantity) VALUES ($1, $2, $3, 0, 0, 0)', [dto.vendorId, dto.productId, dto.storeId]);
            }
            else {
                currentQty = parseInt(res.rows[0].current_quantity);
            }
            if (dto.type === 'ASSIGN') {
                await client.query(`UPDATE vendor_inventories SET assigned_quantity = assigned_quantity + $1, current_quantity = current_quantity + $1, updated_at = NOW() 
           WHERE vendor_id = $2 AND product_id = $3`, [dto.quantity, dto.vendorId, dto.productId]);
                // Deduct from store stock
                await client.query('UPDATE products SET current_stock = current_stock - $1 WHERE id = $2', [dto.quantity, dto.productId]);
            }
            else if (dto.type === 'RETURN') {
                await client.query(`UPDATE vendor_inventories SET current_quantity = current_quantity - $1, updated_at = NOW() 
           WHERE vendor_id = $2 AND product_id = $3`, [dto.quantity, dto.vendorId, dto.productId]);
                // Return to store stock
                await client.query('UPDATE products SET current_stock = current_stock + $1 WHERE id = $2', [dto.quantity, dto.productId]);
            }
            else if (dto.type === 'SALE') {
                await client.query(`UPDATE vendor_inventories SET sold_quantity = sold_quantity + $1, current_quantity = current_quantity - $1, updated_at = NOW() 
           WHERE vendor_id = $2 AND product_id = $3`, [dto.quantity, dto.vendorId, dto.productId]);
            }
            // Log movement
            await client.query(`INSERT INTO movements (store_id, product_id, user_id, type, quantity, balance, reference) 
         VALUES ($1, $2, $3, $4, $5, (SELECT current_stock FROM products WHERE id = $2), $6)`, [dto.storeId, dto.productId, dto.userId, dto.type === 'ASSIGN' ? 'OUT' : 'IN', dto.quantity,
                `Inventario Vendedor: ${dto.type} - Vendor ${dto.vendorId}`]);
            return { success: true, type: dto.type, quantity: dto.quantity };
        });
    }
    mapRow(row) {
        return {
            id: row.id,
            vendorId: row.vendor_id,
            productId: row.product_id,
            storeId: row.store_id,
            description: row.description,
            barcode: row.barcode,
            assignedQuantity: parseInt(row.assigned_quantity || 0),
            soldQuantity: parseInt(row.sold_quantity || 0),
            currentQuantity: parseInt(row.current_quantity || 0),
            updatedAt: row.updated_at,
        };
    }
};
exports.VendorInventoriesService = VendorInventoriesService;
exports.VendorInventoriesService = VendorInventoriesService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], VendorInventoriesService);
