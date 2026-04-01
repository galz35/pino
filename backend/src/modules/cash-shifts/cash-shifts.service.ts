import { Injectable, BadRequestException } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';

@Injectable()
export class CashShiftsService {
  constructor(private readonly db: DatabaseService) {}

  async openShift(storeId: string, userId: string, startingCash: number) {
    const openRes = await this.db.query(
      "SELECT id FROM cash_shifts WHERE store_id = $1 AND status = 'OPEN'",
      [storeId],
    );
    if (openRes.rowCount > 0) throw new BadRequestException('Ya existe un turno de caja abierto en esta tienda');

    const res = await this.db.query(
      `INSERT INTO cash_shifts (store_id, opened_by, starting_cash, actual_cash, status) 
       VALUES ($1, $2, $3, $4, 'OPEN') RETURNING *`,
      [storeId, userId, startingCash, startingCash],
    );
    return this.mapRow(res.rows[0]);
  }

  async closeShift(shiftId: string, storeId: string, expectedCash: number, difference: number, userId: string) {
    const res = await this.db.query(
      `UPDATE cash_shifts 
       SET closed_by = $1, closed_at = NOW(), expected_cash = $2, difference = $3, status = 'CLOSED' 
       WHERE id = $4 AND store_id = $5 AND status = 'OPEN' RETURNING *`,
      [userId, expectedCash, difference, shiftId, storeId],
    );

    if (res.rowCount === 0) throw new BadRequestException('Turno de caja no válido o ya cerrado');
    return this.mapRow(res.rows[0]);
  }

  async getActiveShift(storeId: string) {
    const res = await this.db.query(
      "SELECT * FROM cash_shifts WHERE store_id = $1 AND status = 'OPEN' ORDER BY opened_at DESC LIMIT 1",
      [storeId],
    );
    return res.rowCount > 0 ? this.mapRow(res.rows[0]) : null;
  }

  async findAll(storeId: string, status?: string, cashierId?: string) {
    let sql = 'SELECT * FROM cash_shifts WHERE store_id = $1';
    const params: any[] = [storeId];
    if (status) {
      sql += ` AND status = $${params.push(status.toUpperCase())}`;
    }
    if (cashierId) {
      sql += ` AND opened_by = $${params.push(cashierId)}`;
    }
    sql += ' ORDER BY opened_at DESC LIMIT 50';
    const res = await this.db.query(sql, params);
    return res.rows.map(this.mapRow);
  }

  async findOne(id: string) {
    const res = await this.db.query('SELECT * FROM cash_shifts WHERE id = $1', [id]);
    if (res.rowCount === 0) return null;
    return this.mapRow(res.rows[0]);
  }

  async getShiftStats(shiftId: string) {
    const salesRes = await this.db.query(
      `SELECT payment_method, SUM(total) as total, COUNT(*) as count
       FROM sales 
       WHERE cash_shift_id = $1 
       GROUP BY payment_method`,
      [shiftId],
    );

    const stats: any = {
      cashSales: 0,
      cardSales: 0,
      totalSales: 0,
      salesCount: 0,
    };

    salesRes.rows.forEach((row) => {
      const val = parseFloat(row.total);
      const count = parseInt(row.count);
      if (row.payment_method === 'CASH') stats.cashSales += val;
      if (row.payment_method === 'CARD') stats.cardSales += val;
      stats.totalSales += val;
      stats.salesCount += count;
    });

    return stats;
  }

  private mapRow(row: any): any {
    return {
      id: row.id,
      storeId: row.store_id,
      openedBy: row.opened_by,
      closedBy: row.closed_by,
      openedAt: row.opened_at,
      closedAt: row.closed_at,
      startingCash: parseFloat(row.starting_cash || 0),
      actualCash: parseFloat(row.actual_cash || 0),
      expectedCash: row.expected_cash ? parseFloat(row.expected_cash) : null,
      difference: row.difference ? parseFloat(row.difference) : null,
      status: row.status,
    };
  }
}
