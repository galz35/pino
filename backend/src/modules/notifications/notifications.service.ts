import { Injectable, Logger } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';
import { EventsGateway } from '../../common/gateways/events.gateway';

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger('NotificationsService');

  constructor(
    private readonly db: DatabaseService,
    private readonly events: EventsGateway,
  ) {}

  async findAll(storeId?: string, limit?: number) {
    let q = 'SELECT * FROM notifications';
    const params: any[] = [];
    if (storeId) {
      q += ' WHERE store_id = $1';
      params.push(storeId);
    }
    q += ' ORDER BY created_at DESC LIMIT $' + (params.length + 1);
    params.push(limit || 50);

    const res = await this.db.query(q, params);
    return res.rows.map(this.mapRow);
  }

  async create(dto: {
    storeId: string;
    userId?: string;
    type: string;
    title: string;
    message: string;
    metadata?: any;
  }) {
    const res = await this.db.query(
      `INSERT INTO notifications (store_id, user_id, type, title, message, metadata, read)
       VALUES ($1, $2, $3, $4, $5, $6, false) RETURNING *`,
      [
        dto.storeId,
        dto.userId || null,
        dto.type,
        dto.title,
        dto.message,
        JSON.stringify(dto.metadata || {}),
      ],
    );
    const notification = this.mapRow(res.rows[0]);

    // Broadcast via WebSocket to connected dashboards
    this.events.emitSyncUpdate({
      type: 'NOTIFICATION',
      payload: notification,
      storeId: dto.storeId,
    });

    return notification;
  }

  async markAsRead(id: string) {
    const res = await this.db.query(
      'UPDATE notifications SET read = true WHERE id = $1 RETURNING *',
      [id],
    );
    if (res.rowCount === 0) return null;
    return this.mapRow(res.rows[0]);
  }

  async markAllAsRead(storeId: string) {
    await this.db.query(
      'UPDATE notifications SET read = true WHERE store_id = $1 AND read = false',
      [storeId],
    );
    return { updated: true };
  }

  private mapRow(row: any) {
    return {
      id: row.id,
      storeId: row.store_id,
      userId: row.user_id,
      type: row.type,
      title: row.title,
      message: row.message,
      metadata: typeof row.metadata === 'string' ? JSON.parse(row.metadata) : (row.metadata || {}),
      read: row.read,
      createdAt: row.created_at,
    };
  }
}
