import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';

@Injectable()
export class AccountsPayableService {
  constructor(private readonly db: DatabaseService) {}

  async create(dto: {
    storeId: string;
    supplierId: string;
    invoiceId?: string;
    totalAmount: number;
    description?: string;
    dueDate?: string;
  }) {
    const res = await this.db.query(
      `INSERT INTO accounts_payable (store_id, supplier_id, invoice_id, total_amount, remaining_amount, description, due_date)
       VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
      [
        dto.storeId,
        dto.supplierId,
        dto.invoiceId || null,
        dto.totalAmount,
        dto.totalAmount, // remaining starts at total
        dto.description || null,
        dto.dueDate ? new Date(dto.dueDate) : null,
      ],
    );
    return this.mapRow(res.rows[0]);
  }

  async findAll(filters: { storeId?: string; supplierId?: string; pending?: string }) {
    let sql = `SELECT ap.*, s.name as supplier_name
               FROM accounts_payable ap
               LEFT JOIN suppliers s ON s.id = ap.supplier_id
               WHERE 1=1`;
    const params: any[] = [];
    let idx = 1;

    if (filters.storeId) { sql += ` AND ap.store_id = $${idx++}`; params.push(filters.storeId); }
    if (filters.supplierId) { sql += ` AND ap.supplier_id = $${idx++}`; params.push(filters.supplierId); }
    if (filters.pending === 'true') { sql += ` AND ap.status != 'PAID'`; }

    sql += ' ORDER BY ap.due_date ASC NULLS LAST, ap.created_at DESC';
    const res = await this.db.query(sql, params);
    return res.rows.map((r) => ({
      ...this.mapRow(r),
      supplierName: r.supplier_name || '',
    }));
  }

  async findOne(id: string) {
    const res = await this.db.query(
      `SELECT ap.*, s.name as supplier_name
       FROM accounts_payable ap
       LEFT JOIN suppliers s ON s.id = ap.supplier_id
       WHERE ap.id = $1`,
      [id],
    );
    if ((res.rowCount ?? 0) === 0) throw new NotFoundException('Cuenta por pagar no encontrada');

    const account = { ...this.mapRow(res.rows[0]), supplierName: res.rows[0].supplier_name || '' };

    // Get payments history
    const paymentsRes = await this.db.query(
      `SELECT pp.*, u.name as paid_by_name FROM payable_payments pp
       LEFT JOIN users u ON u.id = pp.paid_by
       WHERE pp.account_id = $1 ORDER BY pp.paid_at DESC`,
      [id],
    );

    account.payments = paymentsRes.rows.map((r) => ({
      id: r.id,
      amount: parseFloat(r.amount || 0),
      paymentMethod: r.payment_method,
      notes: r.notes,
      paidBy: r.paid_by,
      paidByName: r.paid_by_name || '',
      paidAt: r.paid_at,
    }));

    return account;
  }

  async addPayment(accountId: string, dto: { amount: number; paymentMethod?: string; notes?: string; paidBy?: string }) {
    if (dto.amount <= 0) throw new BadRequestException('El monto debe ser mayor a 0');

    return this.db.withTransaction(async (client) => {
      const accRes = await client.query(
        'SELECT * FROM accounts_payable WHERE id = $1 FOR UPDATE',
        [accountId],
      );
      if ((accRes.rowCount ?? 0) === 0) throw new NotFoundException('Cuenta por pagar no encontrada');

      const account = accRes.rows[0];
      const remaining = parseFloat(account.remaining_amount);
      if (dto.amount > remaining) throw new BadRequestException('El monto excede el saldo pendiente');

      const newRemaining = Math.max(0, remaining - dto.amount);
      const newStatus = newRemaining <= 0 ? 'PAID' : 'PARTIAL';

      await client.query(
        'UPDATE accounts_payable SET remaining_amount = $1, status = $2, updated_at = NOW() WHERE id = $3',
        [newRemaining, newStatus, accountId],
      );

      await client.query(
        `INSERT INTO payable_payments (account_id, amount, payment_method, notes, paid_by)
         VALUES ($1, $2, $3, $4, $5)`,
        [accountId, dto.amount, dto.paymentMethod || 'TRANSFER', dto.notes || null, dto.paidBy || null],
      );

      return this.findOne(accountId);
    });
  }

  private mapRow(row: any): any {
    return {
      id: row.id,
      storeId: row.store_id,
      supplierId: row.supplier_id,
      invoiceId: row.invoice_id,
      totalAmount: parseFloat(row.total_amount || 0),
      remainingAmount: parseFloat(row.remaining_amount || 0),
      description: row.description,
      status: row.status,
      dueDate: row.due_date,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    };
  }
}
