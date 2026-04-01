import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';
import { EventsGateway } from '../../common/gateways/events.gateway';

@Injectable()
export class VisitLogsService {
  constructor(
    private readonly db: DatabaseService,
    private readonly eventsGateway: EventsGateway,
  ) {}

  async findAll(storeId: string, days?: number) {
    const daysNum = days || 30;
    const res = await this.db.query(
      `SELECT * FROM visit_logs 
       WHERE store_id = $1 AND created_at >= NOW() - INTERVAL '1 day' * $2 
       ORDER BY created_at DESC`,
      [storeId, daysNum],
    );
    return res.rows.map(this.mapRow);
  }

  async create(dto: { storeId: string; vendorId: string; clientId: string; notes?: string; latitude?: number; longitude?: number }) {
    const res = await this.db.query(
      `INSERT INTO visit_logs (store_id, vendor_id, client_id, notes, latitude, longitude) 
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
      [dto.storeId, dto.vendorId, dto.clientId, dto.notes || null, dto.latitude || null, dto.longitude || null],
    );
    const log = this.mapRow(res.rows[0]);
    
    // Broadcast for Real-time Dashboard
    this.eventsGateway.emitSyncUpdate({
      type: 'NEW_VISIT',
      storeId: log.storeId,
      payload: log
    });

    return log;
  }

  private mapRow(row: any): any {
    return {
      id: row.id,
      storeId: row.store_id,
      vendorId: row.vendor_id,
      clientId: row.client_id,
      notes: row.notes,
      latitude: row.latitude,
      longitude: row.longitude,
      createdAt: row.created_at,
    };
  }
}
