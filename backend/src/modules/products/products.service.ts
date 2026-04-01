import { Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';

@Injectable()
export class ProductsService {
  constructor(private readonly db: DatabaseService) {}

  async create(dto: any) {
    const res = await this.db.query(
      `INSERT INTO products (store_id, department_id, barcode, description, sale_price, cost_price, current_stock, units_per_bulk, stock_bulks, stock_units)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) RETURNING *`,
      [
        dto.storeId, dto.departmentId || null, dto.barcode || null, dto.description,
        dto.salePrice || 0, dto.costPrice || 0, dto.currentStock || 0,
        dto.unitsPerBulk || 1, dto.stockBulks || 0, dto.stockUnits || 0,
      ],
    );
    return this.mapRow(res.rows[0]);
  }

  async findAll(storeId: string, search?: string, departmentId?: string, subDepartmentId?: string, limit: number = 1000, offset: number = 0) {
    let query = `SELECT p.*, d.name as department_name 
                 FROM products p 
                 LEFT JOIN departments d ON p.department_id = d.id 
                 WHERE p.store_id = $1 AND p.is_active = true`;
    const params: any[] = [storeId];
    let pIdx = 2;

    if (search) {
      query += ` AND (p.description ILIKE $${pIdx} OR p.barcode = $${pIdx+1})`;
      params.push(`%${search}%`, search);
      pIdx += 2;
    }

    if (departmentId) {
      query += ` AND p.department_id = $${pIdx++}`;
      params.push(departmentId);
    }

    if (subDepartmentId) {
      query += ` AND p.sub_department_id = $${pIdx++}`;
      params.push(subDepartmentId);
    }

    query += ` ORDER BY p.description ASC LIMIT $${pIdx} OFFSET $${pIdx+1}`;
    params.push(limit, offset);

    const res = await this.db.query(query, params);
    return res.rows.map(this.mapRow);
  }

  async findOne(id: string) {
    const res = await this.db.query(
      `SELECT p.*, d.name as department_name 
       FROM products p 
       LEFT JOIN departments d ON p.department_id = d.id 
       WHERE p.id = $1`,
      [id],
    );
    if (res.rowCount === 0) throw new NotFoundException('Producto no encontrado');
    return this.mapRow(res.rows[0]);
  }

  async findByBarcode(storeId: string, barcode: string) {
    const res = await this.db.query(
      `SELECT p.*, d.name as department_name 
       FROM products p 
       LEFT JOIN departments d ON p.department_id = d.id 
       WHERE p.store_id = $1 AND p.barcode = $2 AND p.is_active = true`,
      [storeId, barcode],
    );
    if (res.rowCount === 0) throw new NotFoundException('Producto con este código no encontrado');
    return this.mapRow(res.rows[0]);
  }

  async update(id: string, dto: any) {
    const fieldMap: Record<string, string> = {
      description: 'description',
      barcode: 'barcode',
      salePrice: 'sale_price',
      costPrice: 'cost_price',
      currentStock: 'current_stock',
      departmentId: 'department_id',
      isActive: 'is_active',
      unitsPerBulk: 'units_per_bulk',
      stockBulks: 'stock_bulks',
      stockUnits: 'stock_units',
      price1: 'price1',
      price2: 'price2',
      price3: 'price3',
      price4: 'price4',
      price5: 'price5',
    };

    const sets: string[] = [];
    const params: any[] = [];
    let idx = 1;

    for (const [camel, snake] of Object.entries(fieldMap)) {
      if (dto[camel] !== undefined) {
        sets.push(`${snake} = $${idx++}`);
        params.push(dto[camel]);
      }
    }

    if (sets.length === 0) return this.findOne(id);

    sets.push(`updated_at = NOW()`);
    params.push(id);

    await this.db.query(
      `UPDATE products SET ${sets.join(', ')} WHERE id = $${idx}`,
      params,
    );
    return this.findOne(id);
  }

  async remove(id: string) {
    await this.db.query('UPDATE products SET is_active = false WHERE id = $1', [id]);
    return this.findOne(id);
  }

  async updateStock(id: string, quantity: number) {
    await this.db.query('UPDATE products SET current_stock = $1 WHERE id = $2', [quantity, id]);
    return this.findOne(id);
  }

  /**
   * Bulk import products with automatic department mapping and inventory movement logging
   */
  async importBulk(dto: {
    storeId: string;
    products: any[];
    cashierName: string;
  }) {
    return this.db.withTransaction(async (client) => {
      // 1. Pre-fetch existing departments for mapping
      const deptsRes = await client.query(
        'SELECT id, name FROM departments WHERE store_id = $1',
        [dto.storeId],
      );
      const deptMap = new Map(deptsRes.rows.map((d) => [d.name, d.id]));

      let importedCount = 0;

      for (const product of dto.products) {
        // Resolve department ID
        let departmentId = null;
        if (product.department) {
          departmentId = deptMap.get(product.department);
          if (!departmentId) {
            // Auto-create department
            const newDept = await client.query(
              'INSERT INTO departments (store_id, name) VALUES ($1, $2) RETURNING id',
              [dto.storeId, product.department],
            );
            departmentId = newDept.rows[0].id;
            deptMap.set(product.department, departmentId);
          }
        }

        // Insert product
        const prodRes = await client.query(
          `INSERT INTO products (store_id, department_id, barcode, description, 
            sale_price, cost_price, price1, price2, price3, price4, price5,
            current_stock, min_stock, sub_department)
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14) RETURNING id`,
          [
            dto.storeId, departmentId, product.barcode || null, product.description,
            product.salePrice || 0, product.costPrice || 0,
            product.price1 || 0, product.price2 || 0, product.price3 || 0,
            product.price4 || 0, product.price5 || 0,
            product.currentStock || 0, product.minStock || 0,
            product.subDepartment || null,
          ],
        );
        const productId = prodRes.rows[0].id;

        // Log initial inventory movement if applicable
        const stock = product.currentStock || 0;
        if (product.usesInventory && stock > 0) {
          await client.query(
            `INSERT INTO movements (store_id, product_id, type, quantity, balance, reference)
             VALUES ($1, $2, 'IN', $3, $4, $5)`,
            [dto.storeId, productId, stock, stock, 'Inventario Inicial (Importación)'],
          );
        }

        importedCount++;
      }

      return { success: true, importedCount };
    });
  }

  private mapRow(row: any): any {
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
      price1: parseFloat(row.price1 || row.sale_price || 0),
      price2: parseFloat(row.price2 || row.sale_price || 0),
      price3: parseFloat(row.price3 || row.sale_price || 0),
      price4: parseFloat(row.price4 || row.sale_price || 0),
      price5: parseFloat(row.price5 || row.sale_price || 0),
      currentStock: parseInt(row.current_stock || 0),
      unitsPerBulk: parseInt(row.units_per_bulk || 1),
      stockBulks: parseInt(row.stock_bulks || 0),
      stockUnits: parseInt(row.stock_units || 0),
      minStock: parseInt(row.min_stock || 0),
      usesInventory: row.uses_inventory !== false,
      supplierId: row.supplier_id || null,
      subDepartment: row.sub_department || '',
      isActive: row.is_active,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    };
  }
}
