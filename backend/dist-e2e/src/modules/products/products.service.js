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
exports.ProductsService = void 0;
const common_1 = require("@nestjs/common");
const database_service_1 = require("../../database/database.service");
let ProductsService = class ProductsService {
    constructor(db) {
        this.db = db;
    }
    async create(dto) {
        const res = await this.db.query(`INSERT INTO products (store_id, department_id, barcode, description, brand, sale_price, cost_price, 
        wholesale_price, price1, price2, price3, price4, price5, current_stock, min_stock, uses_inventory, supplier_id, sub_department)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18) RETURNING *`, [
            dto.storeId, dto.departmentId || null, dto.barcode || null, dto.description,
            dto.brand || null, dto.salePrice || 0, dto.costPrice || 0,
            dto.wholesalePrice || 0, dto.price1 || 0, dto.price2 || 0, dto.price3 || 0,
            dto.price4 || 0, dto.price5 || 0, dto.currentStock || 0, dto.minStock || 0,
            dto.usesInventory !== undefined ? dto.usesInventory : true,
            dto.supplierId || null, dto.subDepartment || null,
        ]);
        return this.mapRow(res.rows[0]);
    }
    async findAll(storeId, search) {
        let query = `SELECT p.*, d.name as department_name 
                 FROM products p 
                 LEFT JOIN departments d ON p.department_id = d.id 
                 WHERE p.store_id = $1 AND p.is_active = true`;
        const params = [storeId];
        if (search) {
            query += ' AND (p.description ILIKE $2 OR p.barcode = $3)';
            params.push(`%${search}%`, search);
        }
        query += ' ORDER BY p.description ASC';
        const res = await this.db.query(query, params);
        return res.rows.map(this.mapRow);
    }
    async findOne(id) {
        const res = await this.db.query(`SELECT p.*, d.name as department_name 
       FROM products p 
       LEFT JOIN departments d ON p.department_id = d.id 
       WHERE p.id = $1`, [id]);
        if (res.rowCount === 0)
            throw new common_1.NotFoundException('Producto no encontrado');
        return this.mapRow(res.rows[0]);
    }
    async findByBarcode(storeId, barcode) {
        const res = await this.db.query(`SELECT p.*, d.name as department_name 
       FROM products p 
       LEFT JOIN departments d ON p.department_id = d.id 
       WHERE p.store_id = $1 AND p.barcode = $2 AND p.is_active = true`, [storeId, barcode]);
        if (res.rowCount === 0)
            throw new common_1.NotFoundException('Producto con este código no encontrado');
        return this.mapRow(res.rows[0]);
    }
    async update(id, dto) {
        const fieldMap = {
            description: 'description',
            barcode: 'barcode',
            brand: 'brand',
            salePrice: 'sale_price',
            costPrice: 'cost_price',
            wholesalePrice: 'wholesale_price',
            price1: 'price1',
            price2: 'price2',
            price3: 'price3',
            price4: 'price4',
            price5: 'price5',
            currentStock: 'current_stock',
            minStock: 'min_stock',
            usesInventory: 'uses_inventory',
            departmentId: 'department_id',
            supplierId: 'supplier_id',
            subDepartment: 'sub_department',
            isActive: 'is_active',
        };
        const sets = [];
        const params = [];
        let idx = 1;
        for (const [camel, snake] of Object.entries(fieldMap)) {
            if (dto[camel] !== undefined) {
                sets.push(`${snake} = $${idx++}`);
                params.push(dto[camel]);
            }
        }
        if (sets.length === 0)
            return this.findOne(id);
        sets.push(`updated_at = NOW()`);
        params.push(id);
        await this.db.query(`UPDATE products SET ${sets.join(', ')} WHERE id = $${idx}`, params);
        return this.findOne(id);
    }
    async remove(id) {
        await this.db.query('UPDATE products SET is_active = false WHERE id = $1', [id]);
        return this.findOne(id);
    }
    async updateStock(id, quantity) {
        await this.db.query('UPDATE products SET current_stock = $1 WHERE id = $2', [quantity, id]);
        return this.findOne(id);
    }
    /**
     * Bulk import products with automatic department mapping and inventory movement logging
     */
    async importBulk(dto) {
        return this.db.withTransaction(async (client) => {
            // 1. Pre-fetch existing departments for mapping
            const deptsRes = await client.query('SELECT id, name FROM departments WHERE store_id = $1', [dto.storeId]);
            const deptMap = new Map(deptsRes.rows.map((d) => [d.name, d.id]));
            let importedCount = 0;
            for (const product of dto.products) {
                // Resolve department ID
                let departmentId = null;
                if (product.department) {
                    departmentId = deptMap.get(product.department);
                    if (!departmentId) {
                        // Auto-create department
                        const newDept = await client.query('INSERT INTO departments (store_id, name) VALUES ($1, $2) RETURNING id', [dto.storeId, product.department]);
                        departmentId = newDept.rows[0].id;
                        deptMap.set(product.department, departmentId);
                    }
                }
                // Insert product
                const prodRes = await client.query(`INSERT INTO products (store_id, department_id, barcode, description, brand, 
            sale_price, cost_price, wholesale_price, price1, price2, price3, price4, price5,
            current_stock, min_stock, uses_inventory, sub_department)
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17) RETURNING id`, [
                    dto.storeId, departmentId, product.barcode || null, product.description,
                    product.brand || null,
                    product.salePrice || 0, product.costPrice || 0, product.wholesalePrice || 0,
                    product.price1 || 0, product.price2 || 0, product.price3 || 0,
                    product.price4 || 0, product.price5 || 0,
                    product.currentStock || 0, product.minStock || 0,
                    product.usesInventory !== undefined ? product.usesInventory : true,
                    product.subDepartment || null,
                ]);
                const productId = prodRes.rows[0].id;
                // Log initial inventory movement if applicable
                const stock = product.currentStock || 0;
                if (product.usesInventory && stock > 0) {
                    await client.query(`INSERT INTO movements (store_id, product_id, type, quantity, balance, reference)
             VALUES ($1, $2, 'IN', $3, $4, $5)`, [dto.storeId, productId, stock, stock, 'Inventario Inicial (Importación)']);
                }
                importedCount++;
            }
            return { success: true, importedCount };
        });
    }
    mapRow(row) {
        return {
            id: row.id,
            storeId: row.store_id,
            departmentId: row.department_id,
            departmentName: row.department_name || '',
            barcode: row.barcode,
            description: row.description,
            brand: row.brand || '',
            salePrice: parseFloat(row.sale_price || 0),
            costPrice: parseFloat(row.cost_price || 0),
            wholesalePrice: parseFloat(row.wholesale_price || 0),
            price1: parseFloat(row.price1 || 0),
            price2: parseFloat(row.price2 || 0),
            price3: parseFloat(row.price3 || 0),
            price4: parseFloat(row.price4 || 0),
            price5: parseFloat(row.price5 || 0),
            currentStock: parseInt(row.current_stock || 0),
            minStock: parseInt(row.min_stock || 0),
            usesInventory: row.uses_inventory,
            supplierId: row.supplier_id,
            subDepartment: row.sub_department || '',
            isActive: row.is_active,
            createdAt: row.created_at,
            updatedAt: row.updated_at,
        };
    }
};
exports.ProductsService = ProductsService;
exports.ProductsService = ProductsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], ProductsService);
