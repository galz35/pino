import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';
import { EventsGateway } from '../../common/gateways/events.gateway';

@Injectable()
export class CollectionsService {
  constructor(
    private readonly db: DatabaseService,
    private readonly eventsGateway: EventsGateway,
  ) {}

  async create(dto: {
    storeId: string;
    accountId?: string;
    ruteroId: string;
    clientId?: string;
    amount: number;
    paymentMethod?: string;
    notes?: string;
  }) {
    if (dto.amount <= 0) {
      throw new BadRequestException('El monto del cobro debe ser mayor a 0');
    }

    return this.db.withTransaction(async (client) => {
      // 1. Create collection record
      const colRes = await client.query(
        `INSERT INTO collections (store_id, account_id, rutero_id, client_id, amount, payment_method, notes)
         VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
        [
          dto.storeId,
          dto.accountId || null,
          dto.ruteroId,
          dto.clientId || null,
          dto.amount,
          dto.paymentMethod || 'CASH',
          dto.notes || null,
        ],
      );
      const collection = colRes.rows[0];

      // 2. If linked to an accounts_receivable, update it
      if (dto.accountId) {
        const accRes = await client.query(
          'SELECT * FROM accounts_receivable WHERE id = $1 FOR UPDATE',
          [dto.accountId],
        );

        if ((accRes.rowCount ?? 0) === 0) {
          throw new NotFoundException('Cuenta por cobrar no encontrada');
        }

        const account = accRes.rows[0];
        const newRemaining = Math.max(0, parseFloat(account.remaining_amount) - dto.amount);
        const newStatus = newRemaining <= 0 ? 'PAID' : 'PARTIAL';

        await client.query(
          'UPDATE accounts_receivable SET remaining_amount = $1, status = $2, updated_at = NOW() WHERE id = $3',
          [newRemaining, newStatus, dto.accountId],
        );

        // Also create an account_payment record for traceability
        await client.query(
          `INSERT INTO account_payments (account_id, amount, payment_method, notes, collected_by)
           VALUES ($1, $2, $3, $4, $5)`,
          [dto.accountId, dto.amount, dto.paymentMethod || 'CASH', dto.notes || `Cobro rutero`, dto.ruteroId],
        );
      }

      const result = this.mapRow(collection);

      // 3. Emit realtime event
      this.eventsGateway.emitSyncUpdate({
        type: 'NEW_COLLECTION',
        storeId: dto.storeId,
        payload: result,
      });

      return result;
    });
  }

  async findAll(filters: { storeId?: string; ruteroId?: string; clientId?: string; date?: string }) {
    let sql = `SELECT c.*, cl.name as client_name, u.name as rutero_name
               FROM collections c
               LEFT JOIN clients cl ON cl.id = c.client_id
               LEFT JOIN users u ON u.id = c.rutero_id
               WHERE 1=1`;
    const params: any[] = [];
    let idx = 1;

    if (filters.storeId) { sql += ` AND c.store_id = $${idx++}`; params.push(filters.storeId); }
    if (filters.ruteroId) { sql += ` AND c.rutero_id = $${idx++}`; params.push(filters.ruteroId); }
    if (filters.clientId) { sql += ` AND c.client_id = $${idx++}`; params.push(filters.clientId); }
    if (filters.date) {
      sql += ` AND c.created_at::date = $${idx++}`;
      params.push(filters.date);
    }

    sql += ' ORDER BY c.created_at DESC';
    const res = await this.db.query(sql, params);
    return res.rows.map((r) => ({
      ...this.mapRow(r),
      clientName: r.client_name || '',
      ruteroName: r.rutero_name || '',
    }));
  }

  async getSummary(filters: { storeId: string; ruteroId?: string; date?: string }) {
    let sql = `SELECT 
                 COUNT(*) as total_count,
                 COALESCE(SUM(amount), 0) as total_amount,
                 COALESCE(SUM(CASE WHEN payment_method = 'CASH' THEN amount ELSE 0 END), 0) as cash_total,
                 COALESCE(SUM(CASE WHEN payment_method != 'CASH' THEN amount ELSE 0 END), 0) as other_total
               FROM collections WHERE store_id = $1`;
    const params: any[] = [filters.storeId];
    let idx = 2;

    if (filters.ruteroId) { sql += ` AND rutero_id = $${idx++}`; params.push(filters.ruteroId); }
    if (filters.date) { sql += ` AND created_at::date = $${idx++}`; params.push(filters.date); }

    const res = await this.db.query(sql, params);
    const row = res.rows[0];
    return {
      totalCount: parseInt(row.total_count || 0),
      totalAmount: parseFloat(row.total_amount || 0),
      cashTotal: parseFloat(row.cash_total || 0),
      otherTotal: parseFloat(row.other_total || 0),
    };
  }

  private mapRow(row: any): any {
    return {
      id: row.id,
      storeId: row.store_id,
      accountId: row.account_id,
      ruteroId: row.rutero_id,
      clientId: row.client_id,
      amount: parseFloat(row.amount || 0),
      paymentMethod: row.payment_method,
      notes: row.notes,
      createdAt: row.created_at,
    };
  }
}
