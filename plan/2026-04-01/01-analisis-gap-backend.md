# 01 — Análisis de Brechas: Backend NestJS

**Referencia:** Secciones 6-17, 21.4 del requerimiento.txt

---

## 1. Inventario de Módulos Backend Existentes vs Requeridos

### Leyenda
- ✅ Existe y cumple el requerimiento
- ⚠️ Existe pero incompleto
- ❌ No existe

| Módulo Requerido | Estado | Archivo(s) | Brecha |
|-----------------|--------|------------|--------|
| Autenticación + JWT | ✅ | `modules/auth/` | — |
| Usuarios + Roles | ✅ | `modules/users/` | Falta restricción por rol en guards |
| Tiendas | ✅ | `modules/stores/` | — |
| Cadenas | ✅ | `modules/chains/` | — |
| Productos | ⚠️ | `modules/products/` | Falta: bultos/unidades, conversión |
| Departamentos | ✅ | `modules/departments/` | — |
| Inventario Bodega | ⚠️ | `modules/inventory/` | Falta: rectificación formal, bultos/unidades |
| Inventario Rutero | ⚠️ | `modules/vendor-inventories/` | Tabla NO en schema.sql, falta bultos/unidades |
| Transferencia Inv. | ⚠️ | Dentro de vendor-inventories | Falta flujo completo preparar→alistar→cargar |
| Pedidos | ⚠️ | `modules/orders/` | Falta: tipo (contado/crédito), precio aplicado, estados correctos |
| Preparación Pedido | ❌ | — | No existe módulo de preparación/alistamiento |
| Despacho | ⚠️ | `modules/pending-orders/` | Existe dispatch pero sin transferencia de inventario |
| Entregas | ⚠️ | `modules/pending-deliveries/` | Falta: confirmación de entrega, efecto en inventario |
| Cobros | ❌ | — | No existe módulo de cobros del rutero |
| Devoluciones | ❌ | — | No existe tabla, servicio ni controlador |
| Cierre de Caja Rutero | ❌ | — | `cash-shifts` es del POS web, no del rutero |
| Facturas | ✅ | `modules/invoices/` | Funciona para proveedor, falta pago formal |
| CxC | ⚠️ | `modules/accounts-receivable/` | Falta vincular con cobros del rutero |
| CxP | ❌ | — | No existe módulo |
| Rutas | ⚠️ | `modules/routes/` | CRUD básico, sin asignación a camión/vehículo |
| Realtime/Sync | ⚠️ | `modules/sync/` + `common/gateways/` | Solo emite NEW_ORDER, falta inventario y estados |

---

## 2. Detalle de Brechas por Módulo

### 2.1 Productos — Bultos y Unidades (B1)

**Estado actual:**
- `products` table tiene: `current_stock INT` (una sola cantidad)
- `products.service.ts` mapea solo `currentStock` como entero

**Requerimiento (sección 10):**
- Productos manejan **bultos** y **unidades** por separado
- 1 bulto = N unidades (conversión configurable por producto)
- Inventario debe mostrar: "5 bultos, 10 unidades"
- En alistamiento: primero listado en bultos, luego en unidades

**Lo que falta construir:**
1. Columnas en `products`: `units_per_bulk INT`, `stock_bulks INT`, `stock_units INT`
2. Lógica de conversión en el servicio
3. Endpoint para gestionar conversión bulto↔unidad
4. Que todos los módulos que tocan inventario respeten la dualidad

### 2.2 Estados del Pedido (B4)

**Estado actual:**
- `orders.status VARCHAR(30) DEFAULT 'PENDING'`
- Servicio acepta cualquier string en `updateStatus()`

**Requerimiento (sección 8):**
- `RECIBIDO` — pedido llega a bodega
- `EN_PREPARACION` — bodeguero lo prepara
- `CARGADO_CAMION` — subido al camión
- `EN_ENTREGA` — rutero salió a entregar

**Lo que falta construir:**
1. Enum de estados en código backend
2. Validación de transiciones válidas (máquina de estados)
3. Que cada transición emita evento realtime
4. Que la transición `CARGADO_CAMION` dispare transferencia de inventario

### 2.3 Devoluciones (B7)

**Estado actual:** No existe nada.

**Requerimiento (secciones 6.6, 15):**
- El rutero registra devolución desde móvil
- Lo devuelto vuelve a inventario de bodega
- No se debe inventar: si es parcial/total, motivo, impacto contable

**Lo que falta construir:**
1. Tabla `returns` (id, order_id, store_id, rutero_id, created_at)
2. Tabla `return_items` (id, return_id, product_id, quantity_bulks, quantity_units)
3. Módulo NestJS: `ReturnsModule` con controller/service
4. Al crear devolución: incrementar `products.current_stock` + registrar movimiento IN en kárdex
5. Emisión realtime del evento

### 2.4 Cobros del Rutero (B9)

**Estado actual:**
- `AccountsReceivable` existe con `addPayment()` 
- Pero no hay endpoint ni lógica para que el rutero registre cobros desde Flutter

**Requerimiento (secciones 6.5, 14):**
- El rutero cobra desde la app móvil
- Los cobros se vinculan a cuentas por cobrar
- El cobro forma parte del cierre de caja

**Lo que falta construir:**
1. Tabla `collections` (id, store_id, account_id, rutero_id, amount, payment_method, created_at)
2. Módulo `CollectionsModule` 
3. Endpoint POST que: registre cobro, actualice `accounts_receivable.remaining_amount`
4. Endpoint GET para consultar cobros por rutero/fecha

### 2.5 Cuentas por Pagar (B8)

**Estado actual:** No existe.

**Requerimiento (sección 12.3):**
- Control de obligaciones
- Pago de obligaciones/facturas
- Observación: el cliente no detalló lógica contable

**Lo que falta construir:**
1. Tabla `accounts_payable` (id, store_id, supplier_id, invoice_id, total_amount, remaining_amount, status, due_date)
2. Tabla `payable_payments` (id, account_id, amount, payment_method, paid_at)
3. Módulo `AccountsPayableModule`
4. Vincular automáticamente al crear factura de proveedor con `payment_type = 'Crédito'`

### 2.6 Tabla vendor_inventories Faltante en Schema (B2)

**Estado actual:**
- `vendor-inventories.service.ts` hace queries a `vendor_inventories` 
- Pero `schema.sql` NO contiene esta tabla
- También falta `accounts_receivable`, `account_payments`, `pending_orders`, `pending_deliveries`

**Lo que falta:**
Agregar todas las tablas faltantes al schema.sql (ver archivo `04-plan-base-datos.md`)

### 2.7 Realtime Incompleto (B5)

**Estado actual:**
- `EventsGateway` existe con `emitSyncUpdate()`
- Solo se invoca en `OrdersService.create()` con tipo `NEW_ORDER`

**Requerimiento (sección 5):**
- Producto nuevo → aparece en Flutter
- Cambio existencias → se ve en Flutter
- Visibilidad de inventario compartida en tiempo real

**Lo que falta construir:**
1. Eventos: `INVENTORY_UPDATE`, `ORDER_STATUS_CHANGE`, `INVENTORY_TRANSFER`, `NEW_RETURN`, `NEW_COLLECTION`
2. Emitir en: `InventoryService`, `ProductsService`, `VendorInventoriesService`, `ReturnsService`
3. Flutter: listener de Socket.IO que actualice providers locales
4. React: expandir `use-real-time-events.ts` para todos los eventos

---

## 3. Endpoints API Faltantes

### Nuevos endpoints requeridos:

```
POST   /api/returns                    — Crear devolución
GET    /api/returns?storeId=&ruteroId= — Listar devoluciones
GET    /api/returns/:id                — Detalle devolución

POST   /api/collections               — Registrar cobro del rutero
GET    /api/collections?storeId=&ruteroId=&date= — Listar cobros

POST   /api/accounts-payable          — Crear cuenta por pagar
GET    /api/accounts-payable?storeId=  — Listar CxP
POST   /api/accounts-payable/:id/payment — Registrar pago

PATCH  /api/orders/:id/prepare        — Marcar en preparación
PATCH  /api/orders/:id/ready          — Marcar alistado
PATCH  /api/orders/:id/load-truck     — Cargar a camión (+ transferencia inv.)
PATCH  /api/orders/:id/deliver        — Marcar entregado
PATCH  /api/orders/:id/return         — Devolución parcial/total

GET    /api/inventory/warehouse?storeId= — Inventario bodega (bultos+unidades)
GET    /api/inventory/rutero/:ruteroId   — Inventario del rutero

POST   /api/products/:id/bulk-config  — Configurar conversión bulto/unidad
```

### Endpoints existentes que necesitan modificación:

```
POST   /api/orders       — Agregar: paymentType (contado/crédito), priceLevel
PATCH  /api/orders/:id   — Validar máquina de estados + emitir realtime
POST   /api/invoices     — Vincular a CxP si paymentType=Crédito
GET    /api/products     — Retornar stockBulks, stockUnits, unitsPerBulk
```
