import { Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';

@Injectable()
export class PendingDeliveriesService {
  constructor(private readonly db: DatabaseService) {}

  async findAll(filters: { storeId?: string; status?: string; ruteroId?: string; unassigned?: boolean }) {
    let sql = `SELECT pd.*, c.name as client_name, o.total as order_total
               FROM pending_deliveries pd 
               LEFT JOIN clients c ON pd.client_id = c.id 
               LEFT JOIN orders o ON pd.order_id = o.id 
               WHERE 1=1`;
    const params: any[] = [];

    if (filters.storeId) sql += ` AND pd.store_id = $${params.push(filters.storeId)}`;
    if (filters.status) sql += ` AND pd.status = $${params.push(filters.status)}`;
    if (filters.ruteroId) sql += ` AND pd.rutero_id = $${params.push(filters.ruteroId)}`;
    if (filters.unassigned) sql += ' AND pd.rutero_id IS NULL';

    sql += ' ORDER BY pd.created_at DESC';
    const res = await this.db.query(sql, params);
    return res.rows.map(this.mapRow);
  }

  async create(dto: { storeId: string; orderId: string; clientId?: string; address?: string; notes?: string }) {
    const res = await this.db.query(
      `INSERT INTO pending_deliveries (store_id, order_id, client_id, address, notes, status) 
       VALUES ($1, $2, $3, $4, $5, 'Pendiente') RETURNING *`,
      [dto.storeId, dto.orderId, dto.clientId || null, dto.address || null, dto.notes || null],
    );
    return this.mapRow(res.rows[0]);
  }

  async update(id: string, dto: { status?: string; ruteroId?: string }) {
    const sets: string[] = [];
    const params: any[] = [];
    let idx = 1;

    if (dto.status) { sets.push(`status = $${idx++}`); params.push(dto.status); }
    if (dto.ruteroId) { sets.push(`rutero_id = $${idx++}`); params.push(dto.ruteroId); }
    if (sets.length === 0) return;

    sets.push('updated_at = NOW()');
    params.push(id);
    await this.db.query(`UPDATE pending_deliveries SET ${sets.join(', ')} WHERE id = $${idx}`, params);
    return { success: true };
  }

  async assignRoute(dto: { deliveryIds: string[]; ruteroId: string; date?: string }) {
    return await this.db.withTransaction(async (client) => {
      for (const deliveryId of dto.deliveryIds) {
        await client.query(
          `UPDATE pending_deliveries SET rutero_id = $1, status = 'Asignado', route_date = $2, updated_at = NOW() WHERE id = $3`,
          [dto.ruteroId, dto.date || new Date().toISOString(), deliveryId],
        );
      }
      return { success: true, assigned: dto.deliveryIds.length };
    });
  }

  private mapRow(row: any): any {
    return {
      id: row.id,
      storeId: row.store_id,
      orderId: row.order_id,
      clientId: row.client_id,
      clientName: row.client_name,
      orderTotal: row.order_total ? parseFloat(row.order_total) : null,
      ruteroId: row.rutero_id,
      address: row.address,
      notes: row.notes,
      status: row.status,
      routeDate: row.route_date,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    };
  }
}
