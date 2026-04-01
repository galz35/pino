# 06 — Plan de Implementación: React Web

**Referencia:** Brechas del archivo `02-analisis-gap-react.md`

---

## 1. Páginas Nuevas a Crear

### 1.1 Preparación de Pedidos (Bodeguero)

**Archivo:** `pages/store-admin/warehouse/preparation-page.tsx`  
**Ruta:** `/store/:storeId/warehouse/preparation`

**Funcionalidad:**
- Lista de pedidos con estado `RECIBIDO`
- Cada pedido muestra: cliente, total, fecha, cantidad de items
- Botón "Iniciar Preparación" → cambia a `EN_PREPARACION` vía API
- Al iniciar: muestra items del pedido agrupados:
  - **Sección 1:** Listado en BULTOS (por producto)
  - **Sección 2:** Listado en UNIDADES (por producto)
- Checkbox por item para marcar "preparado"
- Botón "Finalizar Preparación" cuando todos marcados

**Hooks/Services utilizados:**
- `GET /api/orders?storeId=X&status=RECIBIDO`
- `PATCH /api/orders/:id/prepare`
- Socket.IO: escuchar `NEW_ORDER` para auto-refresh

---

### 1.2 Alistamiento / Requisa (Bodeguero)

**Archivo:** `pages/store-admin/warehouse/picking-page.tsx`  
**Ruta:** `/store/:storeId/warehouse/picking`

**Funcionalidad:**
- Lista pedidos con estado `EN_PREPARACION`
- Vista detallada de requisa:
  - **Primero:** tabla con productos en bultos (descripción, bultos solicitados, bultos alistados)
  - **Luego:** tabla con productos en unidades (descripción, unidades solicitadas, unidades alistadas)
- Input numérico para ajustar cantidad alistada
- Botón "Alistar Completo" → marca listo para despacho
- Impresión de lista de alistamiento (ticket)

---

### 1.3 Estado de Pedidos (Admin/Bodega)

**Archivo:** `pages/store-admin/orders/order-status-page.tsx`  
**Ruta:** `/store/:storeId/orders/status`

**Funcionalidad:**
- Vista Kanban o tablero con 4 columnas:
  - `RECIBIDO` | `EN_PREPARACION` | `CARGADO_CAMION` | `EN_ENTREGA`
- Cards de pedido con: cliente, total, hora, vendedor
- Drag & drop para avanzar estado (o botones)
- Filtro por fecha
- Badge con contador por columna
- Actualización realtime vía Socket.IO

---

### 1.4 Cuentas por Cobrar (Admin)

**Archivo:** `pages/store-admin/finance/receivables-page.tsx`  
**Ruta:** `/store/:storeId/finance/receivables`

**Funcionalidad:**
- Tabla: Cliente | Pedido | Total | Abonado | Pendiente | Estado | Acciones
- Filtros: pendientes, parciales, pagadas, por cliente
- Detalle: historial de abonos con fecha, monto, método, cobrador
- Registro manual de abono desde web
- Indicador de cobranza del día (totales)

---

### 1.5 Cuentas por Pagar (Admin)

**Archivo:** `pages/store-admin/finance/payables-page.tsx`  
**Ruta:** `/store/:storeId/finance/payables`

**Funcionalidad:**
- Tabla: Proveedor | Factura# | Total | Pagado | Pendiente | Vencimiento | Estado
- Filtros: pendientes, vencidas, pagadas, por proveedor
- Registro de pago
- Creación manual de obligación
- Vinculación automática con facturas de proveedor

---

### 1.6 Devoluciones de Bodega (Bodeguero)

**Archivo:** `pages/store-admin/warehouse/returns-page.tsx`  
**Ruta:** `/store/:storeId/warehouse/returns`

**Funcionalidad:**
- Lista de devoluciones recibidas (registradas por ruteros desde Flutter)
- Detalle: pedido original, productos devueltos (bultos + unidades)
- Confirmación de recepción en bodega
- Efecto en inventario: incremento automático
- Filtro por fecha y rutero

---

## 2. Modificaciones a Páginas Existentes

### 2.1 Products Page
**Archivo:** `products/products-page.tsx`
- Agregar columnas a tabla: `Bultos | Unidades | Und/Bulto`
- Reemplazar columna `Stock` única

### 2.2 Add Product Page  
**Archivo:** `products/add-product-page.tsx`
- Agregar campo: "Unidades por bulto" (`unitsPerBulk`)
- Agregar campos separados: "Stock bultos" y "Stock unidades"
- Agregar los 5 campos de precio (price1-price5)

### 2.3 Inventory Adjustments
**Archivo:** `inventory/inventory-adjustments-page.tsx`
- Agregar toggle: "Ajustar en Bultos / Unidades"
- Mostrar conversión: "3 bultos = 60 unidades (20 und/bulto)"
- Resultado muestra nuevo stock en ambas presentaciones

### 2.4 Pending Orders
**Archivo:** `pending-orders/pending-orders-page.tsx`
- Agregar columna `Tipo` (Contado/Crédito con badge)
- Agregar filtro por estado con los 4 estados confirmados
- Botones de acción por estado

### 2.5 Dispatcher
**Archivo:** `dispatcher/dispatcher-page.tsx`
- Agregar confirmación de transferencia de inventario
- Mostrar resumen: "X bultos + Y unidades salen de bodega"
- Al confirmar despacho: `PATCH /api/orders/:id/load-truck`

### 2.6 Vendor Collections
**Archivo:** `vendors/vendor-collections-page.tsx`
- Vincular con CxC: mostrar saldo original y pendiente
- Detalle de cada abono

### 2.7 Vendor Inventory
**Archivo:** `vendors/vendor-inventory-page.tsx`
- Mostrar en bultos + unidades separados

---

## 3. Services API Nuevos

**Crear en:** `services/`

### `services/warehouse-api.ts`
```typescript
export const warehouseApi = {
  getPreparationOrders: (storeId: string) => 
    apiClient.get(`/orders?storeId=${storeId}&status=RECIBIDO`),
  startPreparation: (orderId: string) => 
    apiClient.patch(`/orders/${orderId}/prepare`),
  loadTruck: (orderId: string, data: TransferData) => 
    apiClient.patch(`/orders/${orderId}/load-truck`, data),
  dispatch: (orderId: string) => 
    apiClient.patch(`/orders/${orderId}/dispatch`),
};
```

### `services/returns-api.ts`
```typescript
export const returnsApi = {
  getAll: (storeId: string, filters?) => 
    apiClient.get(`/returns`, { params: { storeId, ...filters } }),
  getById: (id: string) => apiClient.get(`/returns/${id}`),
  create: (data: CreateReturnDto) => apiClient.post(`/returns`, data),
};
```

### `services/collections-api.ts`
```typescript
export const collectionsApi = {
  getAll: (storeId: string, filters?) => 
    apiClient.get(`/collections`, { params: { storeId, ...filters } }),
  getSummary: (storeId: string, ruteroId: string, date: string) =>
    apiClient.get(`/collections/summary`, { params: { storeId, ruteroId, date } }),
  create: (data: CreateCollectionDto) => apiClient.post(`/collections`, data),
};
```

### `services/accounts-payable-api.ts`
```typescript
export const accountsPayableApi = {
  getAll: (storeId: string, filters?) => 
    apiClient.get(`/accounts-payable`, { params: { storeId, ...filters } }),
  getById: (id: string) => apiClient.get(`/accounts-payable/${id}`),
  create: (data: CreatePayableDto) => apiClient.post(`/accounts-payable`, data),
  addPayment: (id: string, data: PaymentDto) => 
    apiClient.post(`/accounts-payable/${id}/payment`, data),
};
```

---

## 4. Actualización del Router

**Archivo:** `App.tsx`

Agregar rutas:
```typescript
// Warehouse (Bodega)
<Route path="warehouse/preparation" element={<PreparationPage />} />
<Route path="warehouse/picking" element={<PickingPage />} />
<Route path="warehouse/returns" element={<ReturnsPage />} />

// Orders
<Route path="orders/status" element={<OrderStatusPage />} />

// Finance
<Route path="finance/receivables" element={<ReceivablesPage />} />
<Route path="finance/payables" element={<PayablesPage />} />
```

---

## 5. Actualización del Sidebar

Agregar al menú lateral:

```
📦 Bodega
  ├── Preparación de Pedidos
  ├── Alistamiento / Requisa
  ├── Despacho (existente)
  └── Devoluciones Recibidas

📋 Pedidos
  ├── Pedidos Recibidos (existente)
  └── Estado de Pedidos (nuevo)

💰 Finanzas
  ├── Facturas (existente)
  ├── Cuentas por Cobrar (nuevo)
  └── Cuentas por Pagar (nuevo)
```

---

## 6. Actualización de Realtime Events

**Archivo:** `hooks/use-real-time-events.ts`

Agregar listeners:
```typescript
socket.on('INVENTORY_UPDATE', (data) => { /* invalidar cache de productos */ });
socket.on('ORDER_STATUS_CHANGE', (data) => { /* actualizar vista de pedidos */ });
socket.on('NEW_RETURN', (data) => { /* notificar en bodega */ });
socket.on('NEW_COLLECTION', (data) => { /* actualizar CxC */ });
socket.on('INVENTORY_TRANSFER', (data) => { /* actualizar inventario */ });
socket.on('PRODUCT_CREATED', (data) => { /* agregar a lista */ });
socket.on('PRODUCT_UPDATED', (data) => { /* actualizar en lista */ });
```

---

## 7. Orden de Implementación React

1. **Types** — Agregar interfaces faltantes
2. **Services API** — Crear los 4 nuevos servicios
3. **Realtime hook** — Ampliar eventos
4. **Products pages** — Bultos/unidades
5. **Inventory pages** — Bultos/unidades
6. **Preparation page** — Nueva
7. **Picking page** — Nueva
8. **Order status page** — Nueva
9. **Dispatcher page** — Vincular con transferencia
10. **Returns page** — Nueva
11. **Receivables page** — Nueva
12. **Payables page** — Nueva
13. **Router + Sidebar** — Integrar todo
