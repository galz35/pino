import { Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';

@Injectable()
export class ClientsService {
  constructor(private readonly db: DatabaseService) {}

  async create(dto: any) {
    const res = await this.db.query(
      `INSERT INTO clients (store_id, name, email, phone, address) 
       VALUES ($1, $2, $3, $4, $5) RETURNING *`,
      [dto.storeId, dto.name, dto.email || null, dto.phone || null, dto.address || null],
    );
    return this.mapRow(res.rows[0]);
  }

  async findAll(storeId: string) {
    const res = await this.db.query(
      'SELECT * FROM clients WHERE store_id = $1 ORDER BY name ASC',
      [storeId],
    );
    return res.rows.map(this.mapRow);
  }

  async findOne(id: string) {
    const res = await this.db.query('SELECT * FROM clients WHERE id = $1', [id]);
    if (res.rowCount === 0) throw new NotFoundException('Cliente no encontrado');
    return this.mapRow(res.rows[0]);
  }

  async update(id: string, dto: any) {
    const fieldMap: Record<string, string> = {
      name: 'name',
      email: 'email',
      phone: 'phone',
      address: 'address',
    };

    const sets: string[] = [];
    const params: any[] = [];
    let idx = 1;

    for (const [camel, snake] of Object.entries(fieldMap)) {
      if (dto[camel] !== undefined) {
        sets.push(`${snake} = $${idx++}`);
        params.push(dto[camel]);
      }
    }

    if (sets.length === 0) return this.findOne(id);
    params.push(id);

    await this.db.query(
      `UPDATE clients SET ${sets.join(', ')} WHERE id = $${idx}`,
      params,
    );
    return this.findOne(id);
  }

  async remove(id: string) {
    await this.db.query('DELETE FROM clients WHERE id = $1', [id]);
    return { success: true };
  }

  private mapRow(row: any): any {
    return {
      id: row.id,
      storeId: row.store_id,
      name: row.name,
      email: row.email,
      phone: row.phone,
      address: row.address,
      createdAt: row.created_at,
    };
  }
}
