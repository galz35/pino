import { Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';

@Injectable()
export class DailyClosingsService {
  constructor(private readonly db: DatabaseService) {}

  async create(dto: {
    storeId: string;
    ruteroId: string;
    totalSales: number;
    totalCollections: number;
    totalReturns: number;
    cashTotal: number;
    closingDate: string;
    notes?: string;
  }) {
    const res = await this.db.query(
      `INSERT INTO daily_closings (store_id, rutero_id, total_sales, total_collections, total_returns, cash_total, closing_date, notes)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *`,
      [dto.storeId, dto.ruteroId, dto.totalSales, dto.totalCollections, dto.totalReturns, dto.cashTotal, dto.closingDate, dto.notes || null],
    );
    return this.mapRow(res.rows[0]);
  }

  async findAll(filters: { storeId?: string; ruteroId?: string; date?: string }) {
    let sql = `SELECT dc.*, u.name as rutero_name
               FROM daily_closings dc
               LEFT JOIN users u ON u.id = dc.rutero_id
               WHERE 1=1`;
    const params: any[] = [];
    let idx = 1;

    if (filters.storeId) { sql += ` AND dc.store_id = $${idx++}`; params.push(filters.storeId); }
    if (filters.ruteroId) { sql += ` AND dc.rutero_id = $${idx++}`; params.push(filters.ruteroId); }
    if (filters.date) { sql += ` AND dc.closing_date = $${idx++}`; params.push(filters.date); }

    sql += ' ORDER BY dc.closing_date DESC, dc.created_at DESC';
    const res = await this.db.query(sql, params);
    return res.rows.map((r) => ({
      ...this.mapRow(r),
      ruteroName: r.rutero_name || '',
    }));
  }

  async findOne(id: string) {
    const res = await this.db.query(
      `SELECT dc.*, u.name as rutero_name
       FROM daily_closings dc LEFT JOIN users u ON u.id = dc.rutero_id WHERE dc.id = $1`,
      [id],
    );
    if ((res.rowCount ?? 0) === 0) throw new NotFoundException('Cierre no encontrado');
    return { ...this.mapRow(res.rows[0]), ruteroName: res.rows[0].rutero_name || '' };
  }

  private mapRow(row: any): any {
    return {
      id: row.id,
      storeId: row.store_id,
      ruteroId: row.rutero_id,
      totalSales: parseFloat(row.total_sales || 0),
      totalCollections: parseFloat(row.total_collections || 0),
      totalReturns: parseFloat(row.total_returns || 0),
      cashTotal: parseFloat(row.cash_total || 0),
      closingDate: row.closing_date,
      notes: row.notes,
      createdAt: row.created_at,
    };
  }
}
