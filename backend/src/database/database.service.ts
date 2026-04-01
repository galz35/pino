import { Inject, Injectable, Logger } from '@nestjs/common';
import { Pool, PoolClient, QueryResult, QueryResultRow } from 'pg';

@Injectable()
export class DatabaseService {
  private readonly logger = new Logger(DatabaseService.name);

  constructor(@Inject('PG_CONNECTION') private readonly pool: Pool) {
    this.pool.on('error', (err) => {
      this.logger.error('Unexpected error on idle client', err);
      process.exit(-1);
    });
  }

  /**
   * Ejecuta una consulta directa usando el Pool
   */
  async query<T extends QueryResultRow = any>(text: string, params?: any[]): Promise<QueryResult<T>> {
    const start = Date.now();
    const res = await this.pool.query<T>(text, params);
    const duration = Date.now() - start;
    this.logger.debug(`Executed query: { text: ${text}, time: ${duration}ms, rows: ${res.rowCount} }`);
    return res;
  }

  /**
   * Obtiene un cliente dedicado del Pool
   * Ideal para transacciones múltiples
   */
  async getClient(): Promise<PoolClient> {
    return await this.pool.connect();
  }

  /**
   * Envuelve una función dentro de un bloque Transaccional BEGIN / COMMIT
   * Si la función tira error, hace ROLLBACK automáticamente.
   */
  async withTransaction<T>(
    callback: (client: PoolClient) => Promise<T>
  ): Promise<T> {
    const client = await this.getClient();
    try {
      await client.query('BEGIN');
      
      const result = await callback(client);
      
      await client.query('COMMIT');
      return result;
    } catch (e) {
      this.logger.error('Transaction rollback due to error', e.stack);
      await client.query('ROLLBACK');
      throw e;
    } finally {
      client.release();
    }
  }
}
