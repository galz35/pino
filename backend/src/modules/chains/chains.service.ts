import { Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';

@Injectable()
export class ChainsService {
  constructor(private readonly db: DatabaseService) {}

  async create(dto: { name: string; logoUrl?: string; ownerName?: string; ownerEmail?: string }) {
    const res = await this.db.query(
      `INSERT INTO chains (name, logo_url, owner_name, owner_email) 
       VALUES ($1, $2, $3, $4) RETURNING *`,
      [dto.name, dto.logoUrl || null, dto.ownerName || null, dto.ownerEmail || null],
    );
    return this.mapRow(res.rows[0]);
  }

  async findAll() {
    const res = await this.db.query("SELECT * FROM chains WHERE status = 'active' ORDER BY name ASC");
    return res.rows.map(this.mapRow);
  }

  async findOne(id: string) {
    const res = await this.db.query('SELECT * FROM chains WHERE id = $1', [id]);
    if (res.rowCount === 0) throw new NotFoundException('Cadena no encontrada');

    const chain = this.mapRow(res.rows[0]);

    // Fetch stores for this chain
    const storesRes = await this.db.query(
      'SELECT * FROM stores WHERE chain_id = $1 AND is_active = true ORDER BY name ASC',
      [id],
    );
    chain.stores = storesRes.rows.map((s: any) => ({
      id: s.id,
      name: s.name,
      address: s.address,
      phone: s.phone,
      chainId: s.chain_id,
    }));

    return chain;
  }

  async update(id: string, dto: any) {
    const fieldMap: Record<string, string> = {
      name: 'name',
      logoUrl: 'logo_url',
      ownerName: 'owner_name',
      ownerEmail: 'owner_email',
      status: 'status',
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

    sets.push('updated_at = NOW()');
    params.push(id);

    await this.db.query(
      `UPDATE chains SET ${sets.join(', ')} WHERE id = $${idx}`,
      params,
    );
    return this.findOne(id);
  }

  async remove(id: string) {
    await this.db.query("UPDATE chains SET status = 'inactive', updated_at = NOW() WHERE id = $1", [id]);
    return this.findOne(id);
  }

  private mapRow(row: any): any {
    return {
      id: row.id,
      name: row.name,
      logoUrl: row.logo_url,
      ownerName: row.owner_name,
      ownerEmail: row.owner_email,
      status: row.status,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    };
  }
}
