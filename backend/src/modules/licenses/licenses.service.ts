import { Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';

@Injectable()
export class LicensesService {
  constructor(private readonly db: DatabaseService) {}

  async findAll(storeId?: string) {
    let sql = 'SELECT l.*, s.name as store_name FROM licenses l LEFT JOIN stores s ON s.id = l.store_id';
    const params: any[] = [];
    if (storeId) {
      sql += ' WHERE l.store_id = $1';
      params.push(storeId);
    }
    sql += ' ORDER BY l.created_at DESC';
    const res = await this.db.query(sql, params);
    return res.rows.map(this.mapRow);
  }

  async findOne(id: string) {
    const res = await this.db.query(
      'SELECT l.*, s.name as store_name FROM licenses l LEFT JOIN stores s ON s.id = l.store_id WHERE l.id = $1',
      [id],
    );
    if ((res.rowCount ?? 0) === 0) throw new NotFoundException('Licencia no encontrada');
    return this.mapRow(res.rows[0]);
  }

  async create(dto: {
    storeId: string;
    licenseKey?: string;
    type?: string;
    maxUsers?: number;
    endDate?: string;
  }) {
    const key = dto.licenseKey || this.generateKey();
    const res = await this.db.query(
      `INSERT INTO licenses (store_id, license_key, type, max_users, end_date)
       VALUES ($1, $2, $3, $4, $5) RETURNING *`,
      [dto.storeId, key, dto.type || 'standard', dto.maxUsers || 5, dto.endDate || null],
    );
    return this.mapRow(res.rows[0]);
  }

  async update(id: string, dto: { status?: string; type?: string; maxUsers?: number; endDate?: string }) {
    const sets: string[] = [];
    const params: any[] = [];
    let idx = 1;
    if (dto.status) { sets.push(`status = $${idx++}`); params.push(dto.status); }
    if (dto.type) { sets.push(`type = $${idx++}`); params.push(dto.type); }
    if (dto.maxUsers !== undefined) { sets.push(`max_users = $${idx++}`); params.push(dto.maxUsers); }
    if (dto.endDate !== undefined) { sets.push(`end_date = $${idx++}`); params.push(dto.endDate || null); }
    if (sets.length === 0) throw new NotFoundException('Nada que actualizar');
    sets.push(`updated_at = NOW()`);
    params.push(id);
    const res = await this.db.query(
      `UPDATE licenses SET ${sets.join(', ')} WHERE id = $${idx} RETURNING *`,
      params,
    );
    if ((res.rowCount ?? 0) === 0) throw new NotFoundException('Licencia no encontrada');
    return this.mapRow(res.rows[0]);
  }

  async delete(id: string) {
    const res = await this.db.query('DELETE FROM licenses WHERE id = $1 RETURNING id', [id]);
    if ((res.rowCount ?? 0) === 0) throw new NotFoundException('Licencia no encontrada');
    return { deleted: true, id };
  }

  private generateKey(): string {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    const segments = 4;
    const segLen = 4;
    const parts: string[] = [];
    for (let s = 0; s < segments; s++) {
      let seg = '';
      for (let i = 0; i < segLen; i++) {
        seg += chars.charAt(Math.floor(Math.random() * chars.length));
      }
      parts.push(seg);
    }
    return parts.join('-');
  }

  private mapRow(row: any) {
    return {
      id: row.id,
      storeId: row.store_id,
      storeName: row.store_name || null,
      licenseKey: row.license_key,
      status: row.status,
      type: row.type,
      startDate: row.start_date,
      endDate: row.end_date,
      maxUsers: row.max_users,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    };
  }
}
