import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from '@nestjs/common';

@Injectable()
export class StoreAccessGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const user = request.user;
    if (!user) throw new ForbiddenException('No autenticado');

    // Master admins can access any store
    if (user.role === 'master-admin') return true;

    // Get storeId from params, query, or body
    const storeId =
      request.params?.storeId ||
      request.query?.storeId ||
      request.body?.storeId;

    if (!storeId) return true; // No store context, allow (controller will handle)

    // Check if user has access to this store
    const userStoreIds: string[] = user.storeIds || [];
    if (!userStoreIds.includes(storeId)) {
      throw new ForbiddenException('No tiene acceso a esta tienda');
    }

    return true;
  }
}
