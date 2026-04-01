import { Injectable, Logger } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';

@Injectable()
export class SyncService {
  private readonly logger = new Logger(SyncService.name);

  constructor(private readonly db: DatabaseService) {}

  async getStatuses() {
    const res = await this.db.query(`
      SELECT 
        id, 
        store_id, 
        status, 
        created_at 
      FROM sync_logs 
      WHERE (store_id, created_at) IN (
        SELECT store_id, MAX(created_at) 
        FROM sync_logs 
        GROUP BY store_id
      )
    `);

    const statuses: any = {};
    res.rows.forEach(row => {
      statuses[row.store_id] = {
        isOnline: true, // Por defecto asumimos online si hay logs recientes
        pendingCount: row.status === 'PENDING' ? 1 : 0,
        failedCount: row.status === 'FAILED' ? 1 : 0,
        lastSyncTimestamp: row.created_at ? new Date(row.created_at).getTime() : null,
      };
    });
    return statuses;
  }

  /**
   * Recibe una carga batch de operaciones realizadas en el frontend durante modo offline
   * Procesa todo dentro de una única transacción SQL para asegurar consistencia
   */
  async processBatchSync(storeId: string, operations: any[] = []) {
    const ops = operations || [];
    this.logger.log(`Recibiendo batch de ${ops.length} operaciones para tienda ${storeId}`);

    return await this.db.withTransaction(async (client) => {
      const results = [];

      // Guardar el log crudo del intento de sincronización
      await client.query(
        'INSERT INTO sync_logs (store_id, payload, status) VALUES ($1, $2, $3)',
        [storeId, JSON.stringify(operations), 'PROCESSING']
      );

      for (const op of operations) {
        try {
          if (op.type === 'SALE') {
            // Reutilizamos lógica similar a SalesService pero adaptada a la data del batch
            // op.data contiene ticket_number, items, etc.
            const { ticketNumber, cashierId, cashShiftId, items, paymentMethod } = op.data;

            const saleRes = await client.query(
              `INSERT INTO sales (store_id, cash_shift_id, cashier_id, ticket_number, subtotal, tax, total, payment_method, created_at) 
               VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING id`,
              [storeId, cashShiftId, cashierId, ticketNumber, op.data.subtotal, op.data.tax, op.data.total, paymentMethod, op.timestamp]
            );
            const saleId = saleRes.rows[0].id;

            for (const item of items) {
              await client.query(
                `INSERT INTO sale_items (sale_id, product_id, quantity, unit_price, subtotal) 
                 VALUES ($1, $2, $3, $4, $5)`,
                [saleId, item.productId, item.quantity, item.unitPrice, (item.quantity * item.unitPrice)]
              );

              // Actualización de stock y kárdex (Lógica Last-Write-Wins simple p/ Batch)
              const prod = await client.query('SELECT current_stock FROM products WHERE id = $1 FOR UPDATE', [item.productId]);
              if (prod.rowCount > 0) {
                  const newStock = prod.rows[0].current_stock - item.quantity;
                  await client.query('UPDATE products SET current_stock = $1 WHERE id = $2', [newStock, item.productId]);
                  await client.query(
                    `INSERT INTO movements (store_id, product_id, user_id, type, quantity, balance, reference) 
                     VALUES ($1, $2, $3, 'OUT', $4, $5, $6)`,
                    [storeId, item.productId, cashierId, item.quantity, newStock, `Sync Offline: ${ticketNumber}`]
                  );
              }
            }
            results.push({ opId: op.id, status: 'SUCCESS' });
          }
          // Se pueden agregar más tipos: ADJUSTMENT, etc.
        } catch (error) {
          this.logger.error(`Error procesando operación ${op.id}: ${error.message}`);
          results.push({ opId: op.id, status: 'FAILED', error: error.message });
          // En un batch transaccional, si falla uno importante podrías decidir fallar todo
          // O podrías manejar puntos de savepoint. Aquí, por simplicidad de MultiTienda,
          // si algo en la transacción falla, con withTransaction se hará ROLLBACK del bloque entero.
          throw error; 
        }
      }

      await client.query(
        'UPDATE sync_logs SET status = $1 WHERE store_id = $2 AND status = $3',
        ['COMPLETED', storeId, 'PROCESSING']
      );

      return {
        processed: results.length,
        results
      };
    });
  }
}
