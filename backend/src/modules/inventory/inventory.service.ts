import { Injectable, BadRequestException } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';

@Injectable()
export class InventoryService {
  constructor(private readonly db: DatabaseService) {}

  async adjustStock(dto: {
    storeId: string;
    productId: string;
    userId: string;
    type: 'IN' | 'OUT';
    quantity: number;
    reference: string;
  }) {
    return await this.db.withTransaction(async (client) => {
      // 1. Bloquear registro del producto para asegurar transaccion y prevenir dirty reads
      const prodRes = await client.query(
        'SELECT current_stock, units_per_bulk FROM products WHERE id = $1 AND store_id = $2 FOR UPDATE',
        [dto.productId, dto.storeId]
      );
      if (prodRes.rowCount === 0) throw new BadRequestException('Producto no encontrado en esta tienda');

      const currentStock = prodRes.rows[0].current_stock;
      const unitsPerBulk = parseInt(prodRes.rows[0].units_per_bulk || 1);
      
      let newStock = currentStock;
      if (dto.type === 'IN') {
        newStock += dto.quantity;
      } else {
        newStock -= dto.quantity;
        if (newStock < 0) throw new BadRequestException('El ajuste resulta en stock negativo (Operación Denegada)');
      }

      const balanceBulks = Math.floor(newStock / unitsPerBulk);
      const balanceUnits = newStock % unitsPerBulk;
      
      const qtyBulks = Math.floor(dto.quantity / unitsPerBulk);
      const qtyUnits = dto.quantity % unitsPerBulk;

      // 2. Actualizar balance
      await client.query(
        'UPDATE products SET current_stock = $1, stock_bulks = $2, stock_units = $3 WHERE id = $4',
        [newStock, balanceBulks, balanceUnits, dto.productId]
      );

      // 3. Registrar Movimiento de Kárdex
      const movRes = await client.query(
        `INSERT INTO movements (store_id, product_id, user_id, type, quantity, quantity_bulks, quantity_units, balance, balance_bulks, balance_units, reference) 
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) RETURNING *`,
        [dto.storeId, dto.productId, dto.userId, dto.type, dto.quantity, qtyBulks, qtyUnits, newStock, balanceBulks, balanceUnits, dto.reference]
      );

      return movRes.rows[0];
    });
  }

  async getKardex(storeId: string, productId: string) {
    const res = await this.db.query(
      `SELECT m.*, u.name as user_name 
       FROM movements m 
       LEFT JOIN users u ON m.user_id = u.id 
       WHERE m.store_id = $1 AND m.product_id = $2 
       ORDER BY m.created_at DESC`,
      [storeId, productId]
    );
    return res.rows;
  }

  async getMovements(storeId: string, date?: string, type?: string) {
    let sql = `
      SELECT m.*, p.description as product_description, u.name as user_name 
      FROM movements m
      LEFT JOIN products p ON m.product_id = p.id
      LEFT JOIN users u ON m.user_id = u.id
      WHERE m.store_id = $1
    `;
    const params: any[] = [storeId];
    
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
}
