import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';

@Injectable()
export class PendingOrdersService {
  constructor(private readonly db: DatabaseService) {}

  async findAll(storeId: string, status?: string) {
    let sql = `SELECT po.*, c.name as client_name 
               FROM pending_orders po 
               LEFT JOIN clients c ON po.client_id = c.id 
               WHERE po.store_id = $1`;
    const params: any[] = [storeId];
    if (status) sql += ` AND po.status = $${params.push(status)}`;
    sql += ' ORDER BY po.created_at DESC';
    const res = await this.db.query(sql, params);
    return res.rows.map(this.mapRow);
  }

  async create(dto: {
    storeId: string; clientId?: string; clientName?: string;
    items: any[]; total?: number; notes?: string; paymentMethod?: string;
  }) {
    const res = await this.db.query(
      `INSERT INTO pending_orders (store_id, client_id, client_name, items, total, notes, payment_method, status) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, 'Pendiente') RETURNING *`,
      [dto.storeId, dto.clientId || null, dto.clientName || null,
       JSON.stringify(dto.items || []), dto.total || 0, dto.notes || null, dto.paymentMethod || 'Efectivo'],
    );
    return this.mapRow(res.rows[0]);
  }

  async dispatch(dto: { orderIds: string[]; dispatchedBy: string }) {
    return await this.db.withTransaction(async (client) => {
      for (const orderId of dto.orderIds) {
        await client.query(
          `UPDATE pending_orders SET status = 'Despachado', dispatched_by = $1, dispatched_at = NOW(), updated_at = NOW() WHERE id = $2`,
          [dto.dispatchedBy, orderId],
        );
      }
      return { success: true, dispatched: dto.orderIds.length };
    });
  }

  async updateStatus(id: string, status: string) {
    await this.db.query('UPDATE pending_orders SET status = $1, updated_at = NOW() WHERE id = $2', [status, id]);
    return { success: true };
  }

  private mapRow(row: any): any {
    return {
      id: row.id,
      storeId: row.store_id,
      clientId: row.client_id,
      clientName: row.client_name,
      items: typeof row.items === 'string' ? JSON.parse(row.items) : (row.items || []),
      total: parseFloat(row.total || 0),
      notes: row.notes,
      paymentMethod: row.payment_method,
      status: row.status,
      dispatchedBy: row.dispatched_by,
      dispatchedAt: row.dispatched_at,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    };
  }
}
