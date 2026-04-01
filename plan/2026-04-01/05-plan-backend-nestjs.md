# 05 — Plan de Implementación: Backend NestJS

**Referencia:** Brechas B1-B12 del resumen ejecutivo

---

## 1. Módulos Nuevos a Crear

### 1.1 ReturnsModule — Devoluciones (B7)

**Archivos a crear:**
```
modules/returns/
├── returns.module.ts
├── returns.controller.ts
└── returns.service.ts
```

**Endpoints:**
| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/api/returns` | Crear devolución |
| GET | `/api/returns` | Listar (filtros: storeId, ruteroId, orderId, date) |
| GET | `/api/returns/:id` | Detalle con items |

**Lógica del servicio `create()`:**
1. Recibir: `{ storeId, orderId, ruteroId, items: [{ productId, quantityBulks, quantityUnits }] }`
2. Dentro de transacción:
   a. Insertar en `returns` 
   b. Para cada item: insertar en `return_items`
   c. Para cada item: `UPDATE products SET stock_bulks = stock_bulks + $bulks, stock_units = stock_units + $units WHERE id = $productId`
   d. Para cada item: `UPDATE vendor_inventories SET current_bulks = current_bulks - $bulks, current_units = current_units - $units WHERE vendor_id = $ruteroId AND product_id = $productId`
   e. Registrar movimiento IN en `movements`
3. Emitir evento realtime: `{ type: 'NEW_RETURN', storeId, payload }`

---

### 1.2 CollectionsModule — Cobros del Rutero (B9)

**Archivos a crear:**
```
modules/collections/
├── collections.module.ts
├── collections.controller.ts
└── collections.service.ts
```

**Endpoints:**
| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/api/collections` | Registrar cobro |
| GET | `/api/collections` | Listar (filtros: storeId, ruteroId, date, clientId) |
| GET | `/api/collections/summary` | Resumen por rutero y fecha |

**Lógica del servicio `create()`:**
1. Recibir: `{ storeId, accountId, ruteroId, clientId, amount, paymentMethod }`
2. Dentro de transacción:
   a. Insertar en `collections`
   b. Actualizar `accounts_receivable`: restar `remaining_amount`, cambiar `status` si queda en 0
   c. Insertar en `account_payments` (reutilizar lógica existente de `addPayment`)
3. Emitir evento realtime: `{ type: 'NEW_COLLECTION', storeId, payload }`

---

### 1.3 AccountsPayableModule — Cuentas por Pagar (B8)

**Archivos a crear:**
```
modules/accounts-payable/
├── accounts-payable.module.ts
├── accounts-payable.controller.ts
└── accounts-payable.service.ts
```

**Endpoints:**
| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/api/accounts-payable` | Crear CxP |
| GET | `/api/accounts-payable` | Listar (filtros: storeId, pending, supplierId) |
| GET | `/api/accounts-payable/:id` | Detalle |
| POST | `/api/accounts-payable/:id/payment` | Registrar pago |

**Integración con Invoices:**
- Cuando se crea factura con `paymentType = 'Crédito'`: auto-crear `accounts_payable` con mismo monto

---

### 1.4 DailyClosingsModule — Cierre de Caja Rutero (B10)

**Archivos a crear:**
```
modules/daily-closings/
├── daily-closings.module.ts
├── daily-closings.controller.ts
└── daily-closings.service.ts
```

**Endpoints:**
| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/api/daily-closings` | Registrar cierre |
| GET | `/api/daily-closings` | Listar (filtros: storeId, ruteroId, date) |
| GET | `/api/daily-closings/:id` | Detalle |

**Nota:** NO inventar estructura. Solo persistir campos del modelo Flutter existente: `totalSales`, `totalCollections`, `totalReturns`, `cashTotal`, `closingDate`.

---

## 2. Módulos Existentes a Modificar

### 2.1 ProductsModule — Bultos y Unidades (B1)

**Archivo:** `modules/products/products.service.ts`

**Cambios en `create()`:**
- Agregar a INSERT: `units_per_bulk`, `stock_bulks`, `stock_units`

**Cambios en `mapRow()`:**
```typescript
unitsPerBulk: parseInt(row.units_per_bulk || 1),
stockBulks: parseInt(row.stock_bulks || 0),
stockUnits: parseInt(row.stock_units || 0),
```

**Cambios en `update()`:**
- Agregar al fieldMap: `unitsPerBulk → units_per_bulk`, `stockBulks → stock_bulks`, `stockUnits → stock_units`

**Nuevo endpoint:**
- `PATCH /api/products/:id/bulk-config` — Actualizar `units_per_bulk`

---

### 2.2 OrdersModule — Estados y Tipo de Pago (B4)

**Archivo:** `modules/orders/orders.service.ts`

**Cambios en `create()`:**
- Agregar: `payment_type`, `price_level` al INSERT
- Si `payment_type = 'CREDITO'`: auto-crear `accounts_receivable`

**Cambios en `updateStatus()`:**
- Agregar máquina de estados:
```typescript
const VALID_TRANSITIONS = {
  'RECIBIDO': ['EN_PREPARACION'],
  'EN_PREPARACION': ['CARGADO_CAMION'],
  'CARGADO_CAMION': ['EN_ENTREGA'],
  'EN_ENTREGA': ['ENTREGADO'],
};
```
- Al transicionar a `CARGADO_CAMION`: invocar transferencia de inventario
- Emitir evento realtime en cada transición

**Nuevos endpoints auxiliares:**
```
PATCH  /api/orders/:id/prepare      → status = EN_PREPARACION
PATCH  /api/orders/:id/load-truck   → status = CARGADO_CAMION + transferencia inv.
PATCH  /api/orders/:id/dispatch     → status = EN_ENTREGA
PATCH  /api/orders/:id/deliver      → status = ENTREGADO
```

---

### 2.3 InventoryModule — Bultos/Unidades y Nuevos Endpoints (B1)

**Archivo:** `modules/inventory/inventory.service.ts`

**Cambios en `adjustStock()`:**
- Recibir: `quantityBulks`, `quantityUnits` además de `quantity`
- Calcular: `totalUnits = quantityBulks * product.unitsPerBulk + quantityUnits`
- Actualizar `stock_bulks` y `stock_units` además de `current_stock`
- Registrar en movements con los campos nuevos

**Nuevos métodos:**
```typescript
async getWarehouseInventory(storeId: string) {
  // SELECT products con stock_bulks y stock_units > 0
}

async getRuteroInventory(ruteroId: string) {
  // SELECT vendor_inventories con current_bulks y current_units
}

async transferToRutero(dto: { storeId, ruteroId, items: [{productId, bulks, units}] }) {
  // Transacción: restar de products, sumar a vendor_inventories
}
```

---

### 2.4 VendorInventoriesModule — Bultos/Unidades (B1/B2)

**Archivo:** `modules/vendor-inventories/vendor-inventories.service.ts`

**Cambios en `processTransaction()`:**
- Manejar `quantityBulks` y `quantityUnits` por separado
- En ASSIGN: restar de `products.stock_bulks/stock_units`, sumar a `vendor_inventories.current_bulks/current_units`
- En RETURN: inverso
- En SALE: restar de current, sumar a sold

---

### 2.5 InvoicesModule — Vincular con CxP (B8)

**Archivo:** `modules/invoices/invoices.service.ts`

**Cambio en `create()`:**
- Después de crear la factura, si `paymentType = 'Crédito'`:
```typescript
if (dto.paymentType === 'Crédito') {
  await client.query(
    `INSERT INTO accounts_payable (store_id, supplier_id, invoice_id, total_amount, remaining_amount, due_date)
     VALUES ($1, $2, $3, $4, $5, $6)`,
    [dto.storeId, dto.supplierId, invoice.id, dto.total, dto.total, dto.dueDate]
  );
}
```

---

### 2.6 EventsGateway — Eventos Completos (B5)

**Archivo:** `common/gateways/events.gateway.ts`

**Eventos a agregar:**

| Evento | Trigger | Payload |
|--------|---------|---------|
| `INVENTORY_UPDATE` | adjustStock, transferToRutero | `{ storeId, productId, stockBulks, stockUnits }` |
| `ORDER_STATUS_CHANGE` | updateStatus | `{ storeId, orderId, oldStatus, newStatus }` |
| `INVENTORY_TRANSFER` | transferToRutero | `{ storeId, ruteroId, items }` |
| `NEW_RETURN` | returns.create | `{ storeId, returnId, items }` |
| `NEW_COLLECTION` | collections.create | `{ storeId, collectionId, amount }` |
| `PRODUCT_CREATED` | products.create | `{ storeId, product }` |
| `PRODUCT_UPDATED` | products.update | `{ storeId, product }` |

---

## 3. Registrar Módulos Nuevos en AppModule

**Archivo:** `app.module.ts`

Agregar imports:
```typescript
import { ReturnsModule } from './modules/returns/returns.module';
import { CollectionsModule } from './modules/collections/collections.module';
import { AccountsPayableModule } from './modules/accounts-payable/accounts-payable.module';
import { DailyClosingsModule } from './modules/daily-closings/daily-closings.module';
```

---

## 4. Orden de Implementación Backend

1. **Migración BD** (ejecutar SQL de `04-plan-base-datos.md`)
2. **ProductsModule** actualizar (bultos/unidades)
3. **InventoryModule** actualizar (bultos/unidades + transferencias)
4. **OrdersModule** actualizar (estados + payment_type)
5. **VendorInventoriesModule** actualizar (bultos/unidades)
6. **ReturnsModule** crear
7. **CollectionsModule** crear
8. **AccountsPayableModule** crear
9. **DailyClosingsModule** crear
10. **EventsGateway** ampliar con todos los eventos
11. **InvoicesModule** vincular con CxP
12. **Registrar módulos** en AppModule
