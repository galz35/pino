import { Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';
import { EventsGateway } from '../../common/gateways/events.gateway';

@Injectable()
export class OrdersService {
  constructor(
    private readonly db: DatabaseService,
    private readonly eventsGateway: EventsGateway,
  ) {}

  async create(dto: {
    storeId: string;
    clientId?: string;
    clientName?: string;
    vendorId?: string;
    salesManagerName?: string;
    paymentType?: string;
    priceLevel?: number;
    items: { productId: string; quantity: number; unitPrice: number; presentation?: string; priceLevel?: number }[];
    notes?: string;
  }) {
    return this.db.withTransaction(async (client) => {
      const total = dto.items.reduce((sum, i) => sum + i.quantity * i.unitPrice, 0);

      const res = await client.query(
        `INSERT INTO orders (store_id, client_id, client_name, vendor_id, sales_manager_name, total, notes, status, payment_type, price_level)
         VALUES ($1, $2, $3, $4, $5, $6, $7, 'RECIBIDO', $8, $9) RETURNING *`,
        [dto.storeId, dto.clientId || null, dto.clientName || null, dto.vendorId || null, dto.salesManagerName || null, total, dto.notes || null, dto.paymentType || 'CONTADO', dto.priceLevel || 1],
      );
      const order = res.rows[0];

      for (const item of dto.items) {
        await client.query(
          `INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal, presentation, price_level)
           VALUES ($1, $2, $3, $4, $5, $6, $7)`,
          [order.id, item.productId, item.quantity, item.unitPrice, item.quantity * item.unitPrice, item.presentation || 'UNIT', item.priceLevel || 1],
        );
      }

      const finalOrder = this.mapRow(order);
      
      // Notify Web Dashboards in Real-Time
      this.eventsGateway.emitSyncUpdate({
        type: 'NEW_ORDER',
        storeId: finalOrder.storeId,
        payload: finalOrder
      });

      return finalOrder;
    });
  }

  async findAll(filters: {
    storeId?: string;
    status?: string;
    vendorId?: string;
    fromDate?: string;
    toDate?: string;
  }) {
    let sql = 'SELECT * FROM orders WHERE 1=1';
    const params: any[] = [];
    let idx = 1;

    if (filters.storeId) {
      sql += ` AND store_id = $${idx++}`;
      params.push(filters.storeId);
    }
    if (filters.status) {
      sql += ` AND status = $${idx++}`;
      params.push(filters.status.toUpperCase());
    }
    if (filters.vendorId) {
      sql += ` AND vendor_id = $${idx++}`;
      params.push(filters.vendorId);
    }
    if (filters.fromDate) {
      sql += ` AND created_at >= $${idx++}`;
      params.push(new Date(filters.fromDate));
    }
    if (filters.toDate) {
      sql += ` AND created_at <= $${idx++}`;
      params.push(new Date(filters.toDate));
    }

    sql += ' ORDER BY created_at DESC';

    const res = await this.db.query(sql, params);
    return res.rows.map(this.mapRow);
  }

  async findOne(id: string) {
    const res = await this.db.query('SELECT * FROM orders WHERE id = $1', [id]);
    if ((res.rowCount ?? 0) === 0) throw new NotFoundException('Pedido no encontrado');

    const order = this.mapRow(res.rows[0]);

    const itemsRes = await this.db.query(
      `SELECT oi.*, p.description as product_name, p.barcode
       FROM order_items oi
       LEFT JOIN products p ON p.id = oi.product_id
       WHERE oi.order_id = $1`,
      [id],
    );

    order.items = itemsRes.rows.map((r) => ({
      id: r.id,
      productId: r.product_id,
      productName: r.product_name || 'N/A',
      barcode: r.barcode,
      quantity: r.quantity,
      unitPrice: parseFloat(r.unit_price),
      subtotal: parseFloat(r.subtotal),
    }));

    return order;
  }

  async updateStatus(id: string, newStatus: string, updatedBy?: string) {
    const validTransitions: Record<string, string[]> = {
      'RECIBIDO': ['EN_PREPARACION', 'CANCELADO'],
      'EN_PREPARACION': ['ALISTADO', 'CANCELADO'],
      'ALISTADO': ['CARGADO_CAMION'],
      'CARGADO_CAMION': ['EN_ENTREGA'],
      'EN_ENTREGA': ['ENTREGADO', 'DEVUELTO', 'RECHAZADO'],
      'PENDING': ['RECIBIDO', 'CANCELADO'],
    };

    return this.db.withTransaction(async (client) => {
      // 1. Check current status
      const res = await client.query('SELECT store_id, status, vendor_id FROM orders WHERE id = $1 FOR UPDATE', [id]);
      if ((res.rowCount ?? 0) === 0) throw new NotFoundException('Pedido no encontrado');
      
      const currentStatus = res.rows[0].status.toUpperCase();
      const targetStatus = newStatus.toUpperCase();
      const storeId = res.rows[0].store_id;
      const vendorId = res.rows[0].vendor_id;

      if (targetStatus === 'CARGADO_CAMION' && currentStatus !== 'CARGADO_CAMION') {
        if (!vendorId) throw new NotFoundException('El pedido requiere un vendor_id para cargar al camión.');
        const itemsRes = await client.query('SELECT oi.*, p.units_per_bulk FROM order_items oi JOIN products p ON p.id = oi.product_id WHERE oi.order_id = $1', [id]);
        for (const item of itemsRes.rows) {
          const upb = item.units_per_bulk || 1;
          const isBulk = item.presentation === 'BULTO';
          const totalUnits = isBulk ? item.quantity * upb : item.quantity;
          const qtyBulks = Math.floor(totalUnits / upb);
          const qtyUnits = totalUnits % upb;

          // Restar de products
          await client.query(`
            UPDATE products 
            SET current_stock = GREATEST(current_stock - $1, 0),
                stock_bulks = GREATEST(current_stock - $1, 0) / units_per_bulk,
                stock_units = GREATEST(current_stock - $1, 0) % units_per_bulk,
                updated_at = NOW()
            WHERE id = $2
          `, [totalUnits, item.product_id]);

          // Sumar a vendor_inventories
          const viRes = await client.query('SELECT id FROM vendor_inventories WHERE vendor_id = $1 AND product_id = $2 FOR UPDATE', [vendorId, item.product_id]);
          if (viRes.rowCount === 0) {
            await client.query(`
              INSERT INTO vendor_inventories (vendor_id, product_id, store_id, assigned_quantity, current_quantity, assigned_bulks, assigned_units, current_bulks, current_units)
              VALUES ($1, $2, $3, $4, $4, $5, $6, $5, $6)
            `, [vendorId, item.product_id, storeId, totalUnits, qtyBulks, qtyUnits]);
          } else {
            await client.query(`
              UPDATE vendor_inventories 
              SET assigned_quantity = assigned_quantity + $1,
                  current_quantity = current_quantity + $1,
                  assigned_bulks = assigned_bulks + $2,
                  assigned_units = assigned_units + $3,
                  current_bulks = current_bulks + $2,
                  current_units = current_units + $3,
                  updated_at = NOW()
              WHERE id = $4
            `, [totalUnits, qtyBulks, qtyUnits, viRes.rows[0].id]);
          }

          // Kardex
          await client.query(`
            INSERT INTO movements (store_id, product_id, user_id, type, quantity, quantity_bulks, quantity_units, balance, balance_bulks, balance_units, reference)
            SELECT $1, $2, $3, 'OUT', $4, $5, $6, current_stock, stock_bulks, stock_units, $7
            FROM products WHERE id = $2
          `, [storeId, item.product_id, updatedBy || null, totalUnits, qtyBulks, qtyUnits, `Cargado a camión - Pedido ${id}`]);
        }
      }

      if (targetStatus === 'ENTREGADO' && currentStatus !== 'ENTREGADO') {
        if (!vendorId) throw new NotFoundException('El pedido requiere un vendor_id para la entrega.');
        const itemsRes = await client.query('SELECT oi.*, p.units_per_bulk FROM order_items oi JOIN products p ON p.id = oi.product_id WHERE oi.order_id = $1', [id]);
        for (const item of itemsRes.rows) {
          const upb = item.units_per_bulk || 1;
          const isBulk = item.presentation === 'BULTO';
          const totalUnits = isBulk ? item.quantity * upb : item.quantity;
          
          await client.query(`
            UPDATE vendor_inventories 
            SET current_quantity = GREATEST(current_quantity - $1, 0),
                sold_quantity = sold_quantity + $1,
                current_bulks = GREATEST(current_quantity - $1, 0) / $4,
                current_units = GREATEST(current_quantity - $1, 0) % $4,
                updated_at = NOW()
            WHERE vendor_id = $2 AND product_id = $3
          `, [totalUnits, vendorId, item.product_id, upb]);
        }
      }

      const updateRes = await client.query(
        `UPDATE orders SET status = $1, updated_by = $2, updated_at = NOW() WHERE id = $3 RETURNING *`,
        [targetStatus, updatedBy || null, id],
      );
      
      const order = this.mapRow(updateRes.rows[0]);

      // Produce precise realtime event for web dashboards logic tracking
      this.eventsGateway.emitSyncUpdate({
        type: 'ORDER_STATUS_CHANGE',
        storeId: storeId,
        payload: { orderId: id, status: targetStatus, previousStatus: currentStatus, updatedBy },
      });

      return order;
    });
  }

  private mapRow(row: any): any {
    return {
      id: row.id,
      storeId: row.store_id,
      clientId: row.client_id,
      clientName: row.client_name,
      vendorId: row.vendor_id,
      salesManagerName: row.sales_manager_name || 'N/A',
      total: parseFloat(row.total),
      status: row.status,
      paymentType: row.payment_type || 'CONTADO',
      priceLevel: parseInt(row.price_level || 1),
      notes: row.notes,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    };
  }
}
