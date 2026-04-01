import { Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';

@Injectable()
export class StoreZonesService {
  constructor(private readonly db: DatabaseService) {}

  async findAll(storeId: string) {
    const res = await this.db.query(
      'SELECT * FROM store_zones WHERE store_id = $1 ORDER BY name ASC',
      [storeId],
    );
    return res.rows.map(this.mapRow);
  }

  async findOne(id: string) {
    const res = await this.db.query('SELECT * FROM store_zones WHERE id = $1', [id]);
    if (res.rowCount === 0) throw new NotFoundException('Zona no encontrada');
    return this.mapRow(res.rows[0]);
  }

  async create(dto: { name: string; storeId: string; description?: string; color?: string }) {
    const res = await this.db.query(
      `INSERT INTO store_zones (store_id, name, description, color) 
       VALUES ($1, $2, $3, $4) RETURNING *`,
      [dto.storeId, dto.name, dto.description || null, dto.color || null],
    );
    return this.mapRow(res.rows[0]);
  }

  async update(id: string, dto: { name?: string; description?: string; color?: string }) {
    const sets: string[] = [];
    const params: any[] = [];
    let idx = 1;

    if (dto.name !== undefined) { sets.push(`name = $${idx++}`); params.push(dto.name); }
    if (dto.description !== undefined) { sets.push(`description = $${idx++}`); params.push(dto.description); }
    if (dto.color !== undefined) { sets.push(`color = $${idx++}`); params.push(dto.color); }

    if (sets.length === 0) return this.findOne(id);

    sets.push('updated_at = NOW()');
    params.push(id);
    await this.db.query(`UPDATE store_zones SET ${sets.join(', ')} WHERE id = $${idx}`, params);
    return this.findOne(id);
  }

  async remove(id: string) {
    await this.db.query('DELETE FROM store_zones WHERE id = $1', [id]);
    return { success: true };
  }

  private mapRow(row: any): any {
    return {
      id: row.id,
      storeId: row.store_id,
      name: row.name,
      description: row.description,
      color: row.color,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    };
  }
}
