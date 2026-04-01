import { Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';
import { EventsGateway } from '../../common/gateways/events.gateway';

@Injectable()
export class ReturnsService {
  constructor(
    private readonly db: DatabaseService,
    private readonly eventsGateway: EventsGateway,
  ) {}

  async create(dto: {
    storeId: string;
    orderId: string;
    ruteroId: string;
    notes?: string;
    items: Array<{
      productId: string;
      quantityBulks: number;
      quantityUnits: number;
      unitPrice: number;
    }>;
  }) {
    return this.db.withTransaction(async (client) => {
      // Calculate total
      const total = dto.items.reduce((sum, item) => {
        const product_units = item.quantityBulks + item.quantityUnits;
        return sum + product_units * item.unitPrice;
      }, 0);

      // 1. Create return record
      const returnRes = await client.query(
        `INSERT INTO returns (store_id, order_id, rutero_id, notes, total)
         VALUES ($1, $2, $3, $4, $5) RETURNING *`,
        [dto.storeId, dto.orderId, dto.ruteroId, dto.notes || null, total],
      );
      const returnRecord = returnRes.rows[0];

      // 2. Process each item
      for (const item of dto.items) {
        const subtotal = (item.quantityBulks + item.quantityUnits) * item.unitPrice;

        // Insert return item
        await client.query(
          `INSERT INTO return_items (return_id, product_id, quantity_bulks, quantity_units, unit_price, subtotal)
           VALUES ($1, $2, $3, $4, $5, $6)`,
          [returnRecord.id, item.productId, item.quantityBulks, item.quantityUnits, item.unitPrice, subtotal],
        );

        // 3. Return product to warehouse inventory (bodega)
        // Get product to know units_per_bulk for total unit calculation
        const prodRes = await client.query(
          'SELECT current_stock, stock_bulks, stock_units, units_per_bulk FROM products WHERE id = $1 FOR UPDATE',
          [item.productId],
        );

        if (prodRes.rowCount > 0) {
          const product = prodRes.rows[0];
          const unitsPerBulk = product.units_per_bulk || 1;
          const totalUnitsReturned = item.quantityBulks * unitsPerBulk + item.quantityUnits;

          const newStockBulks = (product.stock_bulks || 0) + item.quantityBulks;
          const newStockUnits = (product.stock_units || 0) + item.quantityUnits;
          const newCurrentStock = (product.current_stock || 0) + totalUnitsReturned;

          await client.query(
            'UPDATE products SET current_stock = $1, stock_bulks = $2, stock_units = $3, updated_at = NOW() WHERE id = $4',
            [newCurrentStock, newStockBulks, newStockUnits, item.productId],
          );

          // 4. Reduce from rutero inventory
          await client.query(
            `UPDATE vendor_inventories 
             SET current_quantity = current_quantity - $1, 
                 current_bulks = GREATEST(0, current_bulks - $2), 
                 current_units = GREATEST(0, current_units - $3),
                 updated_at = NOW()
             WHERE vendor_id = $4 AND product_id = $5`,
            [totalUnitsReturned, item.quantityBulks, item.quantityUnits, dto.ruteroId, item.productId],
          );

          // 5. Log movement in kárdex
          await client.query(
            `INSERT INTO movements (store_id, product_id, user_id, type, quantity, balance, quantity_bulks, quantity_units, balance_bulks, balance_units, reference)
             VALUES ($1, $2, $3, 'IN', $4, $5, $6, $7, $8, $9, $10)`,
            [dto.storeId, item.productId, dto.ruteroId, totalUnitsReturned, newCurrentStock,
             item.quantityBulks, item.quantityUnits, newStockBulks, newStockUnits,
             `Devolución #${returnRecord.id.substring(0, 8)}`],
          );
        }
      }

      const result = this.mapRow(returnRecord);

      // 6. Emit realtime event
      this.eventsGateway.emitSyncUpdate({
        type: 'NEW_RETURN',
        storeId: dto.storeId,
        payload: result,
      });

      return result;
    });
  }

  async findAll(filters: { storeId?: string; ruteroId?: string; orderId?: string; fromDate?: string; toDate?: string }) {
    let sql = 'SELECT * FROM returns WHERE 1=1';
    const params: any[] = [];
    let idx = 1;

    if (filters.storeId) { sql += ` AND store_id = $${idx++}`; params.push(filters.storeId); }
    if (filters.ruteroId) { sql += ` AND rutero_id = $${idx++}`; params.push(filters.ruteroId); }
    if (filters.orderId) { sql += ` AND order_id = $${idx++}`; params.push(filters.orderId); }
    if (filters.fromDate) { sql += ` AND created_at >= $${idx++}`; params.push(new Date(filters.fromDate)); }
    if (filters.toDate) { sql += ` AND created_at <= $${idx++}`; params.push(new Date(filters.toDate)); }

    sql += ' ORDER BY created_at DESC';
    const res = await this.db.query(sql, params);
    return res.rows.map(this.mapRow);
  }

  async findOne(id: string) {
    const res = await this.db.query('SELECT * FROM returns WHERE id = $1', [id]);
    if ((res.rowCount ?? 0) === 0) throw new NotFoundException('Devolución no encontrada');

    const returnRecord = this.mapRow(res.rows[0]);

    const itemsRes = await this.db.query(
      `SELECT ri.*, p.description as product_name, p.barcode
       FROM return_items ri
       LEFT JOIN products p ON p.id = ri.product_id
       WHERE ri.return_id = $1`,
      [id],
    );

    returnRecord.items = itemsRes.rows.map((r) => ({
      id: r.id,
      productId: r.product_id,
      productName: r.product_name || 'N/A',
      barcode: r.barcode,
      quantityBulks: parseInt(r.quantity_bulks || 0),
      quantityUnits: parseInt(r.quantity_units || 0),
      unitPrice: parseFloat(r.unit_price || 0),
      subtotal: parseFloat(r.subtotal || 0),
    }));

    return returnRecord;
  }

  private mapRow(row: any): any {
    return {
      id: row.id,
      storeId: row.store_id,
      orderId: row.order_id,
      ruteroId: row.rutero_id,
      notes: row.notes,
      total: parseFloat(row.total || 0),
      createdAt: row.created_at,
    };
  }
}
