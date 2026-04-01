# 02 — Análisis de Brechas: React Web

**Referencia:** Secciones 3.1, 4.1-4.4, 6, 16.1-16.4, 21.1 del requerimiento.txt

---

## 1. Inventario de Páginas React vs Requerimientos

### Leyenda
- ✅ Existe y cumple
- ⚠️ Existe pero incompleto
- ❌ No existe

### Módulo Store Admin (Bodega + Administrador)

| Funcionalidad Requerida | Página Actual | Estado | Brecha |
|------------------------|---------------|--------|--------|
| Login | `login-page.tsx` | ✅ | — |
| Dashboard tienda | `dashboard/` | ✅ | — |
| Productos CRUD | `products/products-page.tsx` | ⚠️ | Falta: bultos/unidades, conversión |
| Agregar producto | `products/add-product-page.tsx` | ⚠️ | Falta: campo unitsPerBulk |
| Departamentos | `products/departments-page.tsx` | ✅ | — |
| Sub-departamentos | `products/sub-departments-page.tsx` | ✅ | — |
| Inventario ajustes | `inventory/inventory-adjustments-page.tsx` | ⚠️ | Falta: ajuste en bultos/unidades |
| Inventario movimientos | `inventory/inventory-movements-page.tsx` | ✅ | — |
| Rectificación inventario | ❌ | ❌ | No existe como flujo separado |
| Pedidos recibidos | `pending-orders/pending-orders-page.tsx` | ⚠️ | Falta: estados confirmados, tipo contado/crédito |
| Preparación pedidos | ❌ | ❌ | No hay pantalla de preparación en web |
| Alistamiento (requisa) | ❌ | ❌ | No hay pantalla de alistamiento bultos→unidades |
| Despacho | `dispatcher/dispatcher-page.tsx` | ⚠️ | Falta: vincular con transferencia de inventario |
| Estado de pedidos | ❌ | ❌ | No hay vista consolidada de estados |
| Rutas de entrega | `delivery-route/delivery-route-page.tsx` | ⚠️ | CRUD básico, sin visualización de ruta |
| Facturas proveedor | `billing/billing-page.tsx` | ✅ | Funcional con entrada a inventario |
| Pago de facturas | ⚠️ | ⚠️ | Solo cambio de status, sin módulo de pagos |
| CxC | ❌ | ❌ | No existe página de cuentas por cobrar |
| CxP | ❌ | ❌ | No existe página de cuentas por pagar |
| Devoluciones bodega | ❌ | ❌ | No existe página |
| Reportes | `reports/reports-page.tsx` | ⚠️ | Shell básico sin reportes reales |
| Usuarios tienda | `users/` | ✅ | — |
| Config tienda | `settings/settings-page.tsx` | ✅ | — |
| Proveedores | `suppliers/` | ✅ | — |
| POS (caja web) | `pos-page.tsx` | ✅ | — |
| Caja registradora | `cash-register/cash-register-page.tsx` | ✅ | — |
| Autorizaciones | `authorizations/authorizations-page.tsx` | ✅ | — |
| Torre de control | `control-tower/control-tower-page.tsx` | ✅ | — |

### Módulo Master Admin

| Funcionalidad Requerida | Página Actual | Estado |
|------------------------|---------------|--------|
| Dashboard master | `master-dashboard-page.tsx` | ✅ |
| Gestión tiendas | `master-stores-page.tsx` | ✅ |
| Crear tienda | `add-store-page.tsx` | ✅ |
| Gestión cadenas | `master-chains-page.tsx` | ✅ |
| Crear cadena | `add-chain-page.tsx` | ✅ |
| Usuarios globales | `master-users-page.tsx` | ✅ |
| Monitor Sync | `master-sync-monitor-page.tsx` | ⚠️ |
| Zonas | `master-zones-page.tsx` | ✅ |
| Sub-zonas | `master-sub-zones-page.tsx` | ✅ |
| Configuración global | `master-config-page.tsx` | ✅ |
| Licencias | `master-licenses-page.tsx` | ✅ |

### Módulo Vendors (Vendedor/Rutero visto desde web)

| Funcionalidad | Página Actual | Estado |
|--------------|---------------|--------|
| Lista vendedores | `vendors-page.tsx` | ✅ |
| Dashboard vendedor | `vendor-dashboard-page.tsx` | ✅ |
| Inventario vendedor | `vendor-inventory-page.tsx` | ⚠️ |
| Rutas vendedor | `vendor-routes-page.tsx` | ✅ |
| Cobros vendedor | `vendor-collections-page.tsx` | ⚠️ |
| Ventas vendedor | `vendor-sales-page.tsx` | ✅ |
| Clientes vendedor | `vendor-clients-page.tsx` | ✅ |
| Zonas vendedor | `vendor-zones-page.tsx` | ✅ |
| Venta rápida | `vendor-quick-sale-page.tsx` | ✅ |
| Asignar ruta | `assign-route-page.tsx` | ✅ |

---

## 2. Páginas Nuevas Requeridas

### Prioridad 1 (Core operativo)

| Página | Ruta propuesta | Funcionalidad |
|--------|---------------|---------------|
| **Preparación de Pedidos** | `/store/:id/warehouse/preparation` | Bodeguero ve pedidos RECIBIDO, los marca EN_PREPARACIÓN, lista productos bultos→unidades |
| **Alistamiento / Requisa** | `/store/:id/warehouse/picking` | Muestra items del pedido: primero bultos, luego unidades. Confirma cantidades alistadas |
| **Estado de Pedidos** | `/store/:id/orders/status` | Vista consolidada: RECIBIDO → EN_PREPARACIÓN → CARGADO → EN_ENTREGA. Cards con progreso |
| **Cuentas por Cobrar** | `/store/:id/finance/receivables` | Lista CxC pendientes, historial de abonos, filtro por cliente |
| **Devoluciones** | `/store/:id/warehouse/returns` | Recepción de devoluciones que regresan de ruta, impacto en inventario |

### Prioridad 2 (Financiero)

| Página | Ruta propuesta | Funcionalidad |
|--------|---------------|---------------|
| **Cuentas por Pagar** | `/store/:id/finance/payables` | Lista CxP a proveedores, registro de pagos, vinculación con facturas |
| **Pago de Facturas** | Dentro de billing | Expandir billing para flujo de pago con registro formal |

---

## 3. Modificaciones a Páginas Existentes

### 3.1 Products Page — Bultos y Unidades
**Archivo:** `products/products-page.tsx` y `add-product-page.tsx`

Cambios:
- Agregar campo `unitsPerBulk` (unidades por bulto) al formulario de producto
- En tabla de productos: mostrar columnas `Bultos | Unidades` en lugar de solo `Stock`
- En importación masiva: mapear columna de conversión

### 3.2 Inventory Adjustments — Doble Stock
**Archivo:** `inventory/inventory-adjustments-page.tsx`

Cambios:
- Selector: ¿Ajustar en bultos o en unidades?
- Si ajusta en bultos: multiplicar por `unitsPerBulk` internamente
- Mostrar resultado: "Nuevo stock: X bultos + Y unidades"

### 3.3 Pending Orders — Estados y Tipo
**Archivo:** `pending-orders/pending-orders-page.tsx`

Cambios:
- Mostrar columna `Tipo` (Contado / Crédito)
- Filtro por estado: Recibido, En Preparación, Cargado, En Entrega
- Badge de color por estado
- Botón de acción según estado actual (ej: "Iniciar Preparación")

### 3.4 Dispatcher — Transferencia de Inventario 
**Archivo:** `dispatcher/dispatcher-page.tsx`

Cambios:
- Al despachar: confirmar que el inventario se transfiere de bodega a rutero
- Mostrar resumen: productos × cantidades (bultos + unidades) que salen de bodega
- Confirmación antes de ejecutar

### 3.5 Vendor Inventory — Bultos y Unidades
**Archivo:** `vendors/vendor-inventory-page.tsx`

Cambios:
- Mostrar inventario del rutero en bultos + unidades
- Histórico de asignaciones/devoluciones

### 3.6 Vendor Collections — Vinculación CxC
**Archivo:** `vendors/vendor-collections-page.tsx`

Cambios:
- Mostrar cobros vinculados a cuentas por cobrar
- Total cobrado vs total pendiente

### 3.7 Sync Monitor — Monitoreo Real
**Archivo:** `master-sync-monitor-page.tsx`

Cambios:
- Mostrar conexiones Socket.IO activas por tienda
- Indicador online/offline por dispositivo Flutter
- Últimos eventos emitidos

---

## 4. Tipos TypeScript Faltantes

**Archivo:** `types/index.ts` — Agregar:

```typescript
// Bultos y Unidades
interface Product {
  // Existentes...
  unitsPerBulk: number;    // Nuevo
  stockBulks: number;      // Nuevo
  stockUnits: number;      // Nuevo
}

// Pedido extendido
interface Order {
  id: string;
  storeId: string;
  clientId?: string;
  clientName?: string;
  vendorId?: string;
  paymentType: 'CONTADO' | 'CREDITO';  // Nuevo
  priceLevel: number;                   // Nuevo (1-5)
  status: 'RECIBIDO' | 'EN_PREPARACION' | 'CARGADO_CAMION' | 'EN_ENTREGA'; // Nuevo
  items: OrderItem[];
  total: number;
  createdAt: string;
}

// Devolución
interface Return {
  id: string;
  orderId: string;
  storeId: string;
  ruteroId: string;
  items: ReturnItem[];
  createdAt: string;
}

// Cobro
interface Collection {
  id: string;
  storeId: string;
  accountId: string;
  ruteroId: string;
  amount: number;
  paymentMethod: string;
  createdAt: string;
}

// Cuenta por pagar
interface AccountPayable {
  id: string;
  storeId: string;
  supplierId: string;
  supplierName: string;
  invoiceId?: string;
  totalAmount: number;
  remainingAmount: number;
  status: 'PENDING' | 'PARTIAL' | 'PAID';
  dueDate?: string;
}
```

---

## 5. Hooks y Services Faltantes

| Hook/Service | Propósito |
|-------------|-----------|
| `useOrderStatus()` | Escuchar cambios de estado de pedidos en realtime |
| `useInventoryRealtime()` | Escuchar actualizaciones de inventario |
| `useWarehousePreparation()` | Lógica de preparación/alistamiento |
| `services/returns-api.ts` | CRUD de devoluciones |
| `services/collections-api.ts` | CRUD de cobros |
| `services/accounts-payable-api.ts` | CRUD de CxP |
| `services/warehouse-api.ts` | Preparación, alistamiento, despacho |
