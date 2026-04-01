import { Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';

@Injectable()
export class VendorInventoriesService {
  constructor(private readonly db: DatabaseService) {}

  async getInventory(vendorId: string, productId: string) {
    const res = await this.db.query(
      'SELECT * FROM vendor_inventories WHERE vendor_id = $1 AND product_id = $2',
      [vendorId, productId],
    );
    if (res.rowCount === 0) {
      return { vendorId, productId, assignedQuantity: 0, soldQuantity: 0, currentQuantity: 0 };
    }
    return this.mapRow(res.rows[0]);
  }

  async getVendorProducts(vendorId: string) {
    const res = await this.db.query(
      `SELECT vi.*, p.description, p.barcode 
       FROM vendor_inventories vi 
       JOIN products p ON vi.product_id = p.id 
       WHERE vi.vendor_id = $1 AND vi.current_quantity > 0 
       ORDER BY p.description ASC`,
      [vendorId],
    );
    return res.rows.map(this.mapRow);
  }

  async processTransaction(dto: {
    vendorId: string;
    productId: string;
    storeId: string;
    type: 'ASSIGN' | 'RETURN' | 'SALE';
    quantity: number;
    userId: string;
  }) {
    return await this.db.withTransaction(async (client) => {
      // Get or create record
      let res = await client.query(
        'SELECT * FROM vendor_inventories WHERE vendor_id = $1 AND product_id = $2 FOR UPDATE',
        [dto.vendorId, dto.productId],
      );

      let currentQty = 0;
      if (res.rowCount === 0) {
        await client.query(
          'INSERT INTO vendor_inventories (vendor_id, product_id, store_id, assigned_quantity, sold_quantity, current_quantity) VALUES ($1, $2, $3, 0, 0, 0)',
          [dto.vendorId, dto.productId, dto.storeId],
        );
      } else {
        currentQty = parseInt(res.rows[0].current_quantity);
      }

      if (dto.type === 'ASSIGN') {
        await client.query(
          `UPDATE vendor_inventories SET assigned_quantity = assigned_quantity + $1, current_quantity = current_quantity + $1, updated_at = NOW() 
           WHERE vendor_id = $2 AND product_id = $3`,
          [dto.quantity, dto.vendorId, dto.productId],
        );
        // Deduct from store stock
        await client.query('UPDATE products SET current_stock = current_stock - $1 WHERE id = $2', [dto.quantity, dto.productId]);
      } else if (dto.type === 'RETURN') {
        await client.query(
          `UPDATE vendor_inventories SET current_quantity = current_quantity - $1, updated_at = NOW() 
           WHERE vendor_id = $2 AND product_id = $3`,
          [dto.quantity, dto.vendorId, dto.productId],
        );
        // Return to store stock
        await client.query('UPDATE products SET current_stock = current_stock + $1 WHERE id = $2', [dto.quantity, dto.productId]);
      } else if (dto.type === 'SALE') {
        await client.query(
          `UPDATE vendor_inventories SET sold_quantity = sold_quantity + $1, current_quantity = current_quantity - $1, updated_at = NOW() 
           WHERE vendor_id = $2 AND product_id = $3`,
          [dto.quantity, dto.vendorId, dto.productId],
        );
      }

      // Log movement
      await client.query(
        `INSERT INTO movements (store_id, product_id, user_id, type, quantity, balance, reference) 
         VALUES ($1, $2, $3, $4, $5, (SELECT current_stock FROM products WHERE id = $2), $6)`,
        [dto.storeId, dto.productId, dto.userId, dto.type === 'ASSIGN' ? 'OUT' : 'IN', dto.quantity,
         `Inventario Vendedor: ${dto.type} - Vendor ${dto.vendorId}`],
      );

      return { success: true, type: dto.type, quantity: dto.quantity };
    });
  }

  private mapRow(row: any): any {
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
      assignedBulks: parseInt(row.assigned_bulks || 0),
      assignedUnits: parseInt(row.assigned_units || 0),
      currentBulks: parseInt(row.current_bulks || 0),
      currentUnits: parseInt(row.current_units || 0),
      updatedAt: row.updated_at,
    };
  }
}
