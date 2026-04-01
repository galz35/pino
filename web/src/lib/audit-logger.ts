import apiClient from '../services/api-client';

interface AuditLog {
  action: string;
  userId: string;
  userName: string;
  storeId?: string;
  details: Record<string, any>;
}

export async function logAudit(log: AuditLog) {
  try {
    // En MultiTienda v2, el backend NestJS maneja su propia auditoría en Postgres
    // para las acciones que pasan por la API. Aquí enviamos logs de acciones de UI.
    console.info(`[Audit Log] ${log.action}`, log);
    
    // Opcional: Descomentar cuando el endpoint de auditoría esté disponible
    // await apiClient.post('/audit/log', log);
  } catch (error) {
    console.error('Failed to log audit action:', error);
  }
}
