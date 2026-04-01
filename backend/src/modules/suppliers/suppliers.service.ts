import { Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';

@Injectable()
export class SuppliersService {
  constructor(private readonly db: DatabaseService) {}

  async create(dto: any) {
    const res = await this.db.query(
      `INSERT INTO suppliers (chain_id, name, contact_name, email, phone, address) 
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
      [dto.chainId || dto.storeId, dto.name, dto.contactName, dto.email, dto.phone, dto.address],
    );
    return this.mapRow(res.rows[0]);
  }

  async findAll(chainId?: string, storeId?: string) {
    let sql = 'SELECT * FROM suppliers WHERE 1=1';
    const params: any[] = [];

    if (chainId) {
      params.push(chainId);
      sql += ` AND chain_id = $${params.length}`;
    }
    if (storeId) {
      // If frontend passes storeId, look up chain_id from stores table
      params.push(storeId);
      sql += ` AND chain_id = (SELECT chain_id FROM stores WHERE id = $${params.length})`;
    }

    sql += ' ORDER BY name ASC';
    const res = await this.db.query(sql, params);
    return res.rows.map(this.mapRow);
  }

  async findOne(id: string) {
    const res = await this.db.query('SELECT * FROM suppliers WHERE id = $1', [id]);
    if (res.rowCount === 0) throw new NotFoundException('Proveedor no encontrado');
    return this.mapRow(res.rows[0]);
  }

  async update(id: string, dto: any) {
    const fieldMap: Record<string, string> = {
      name: 'name',
      contactName: 'contact_name',
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
      `UPDATE suppliers SET ${sets.join(', ')} WHERE id = $${idx}`,
      params,
    );
    return this.findOne(id);
  }

  async remove(id: string) {
    await this.db.query('DELETE FROM suppliers WHERE id = $1', [id]);
    return { success: true };
  }

  private mapRow(row: any): any {
    return {
      id: row.id,
      chainId: row.chain_id,
      name: row.name,
      contactName: row.contact_name,
      email: row.email,
      phone: row.phone,
      address: row.address,
      createdAt: row.created_at,
    };
  }
}
