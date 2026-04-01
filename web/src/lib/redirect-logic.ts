import { User } from '@/types';

/**
 * Normaliza los roles del usuario de NestJS/Postgres y retorna la ruta de dashboard apropiada.
 */
export function getRedirectPath(user: User | null): string | null {
    if (!user) {
        return null;
    }

    const role = user.role?.toLowerCase().trim();
    const storeId = user.storeIds?.[0]; // En v2 usamos el primer storeId asignado por ahora



    // Master Admin / Owner (Acceso global)
    if (role === 'master-admin' || role === 'owner') {
        return '/';
    }

    // Si no tiene tienda asignada y no es admin global, error
    if (!storeId) {
        console.warn(`[RedirectLogic] User with role "${role}" has no assigned storeId.`);
        return '/login?error=no-store';
    }

    // Roles específicos de tienda
    switch (role) {
        case 'store-admin':
        case 'admin':
            return `/store/${storeId}/dashboard`;
        case 'cashier':
        case 'cajero':
            return `/store/${storeId}/pos`;
        case 'inventory':
        case 'bodeguero':
            return `/store/${storeId}/products`;
        case 'dispatcher':
        case 'despacho':
            return `/store/${storeId}/pos`;
        default:
            console.error(`[RedirectLogic] Unrecognized role: "${role}"`);
            return `/store/${storeId}/products`; // Fallback al listado de productos
    }
}
