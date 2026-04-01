import { Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';

@Injectable()
export class ConfigService {
  constructor(private readonly db: DatabaseService) {}

  async getByKey(key: string) {
    const res = await this.db.query('SELECT * FROM config WHERE key = $1', [key]);
    if (res.rowCount === 0) return { key, value: {} };
    return { key: res.rows[0].key, value: res.rows[0].value };
  }

  async upsert(key: string, value: any) {
    const res = await this.db.query(
      `INSERT INTO config (key, value, updated_at) VALUES ($1, $2, NOW())
       ON CONFLICT (key) DO UPDATE SET value = $2, updated_at = NOW()
       RETURNING *`,
      [key, JSON.stringify(value)],
    );
    return { key: res.rows[0].key, value: res.rows[0].value };
  }

  async getAll() {
    const res = await this.db.query('SELECT * FROM config ORDER BY key ASC');
    return res.rows.map((r) => ({ key: r.key, value: r.value }));
  }
}
