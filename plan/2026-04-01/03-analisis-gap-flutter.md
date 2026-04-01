# 03 — Análisis de Brechas: Flutter Móvil

**Referencia:** Secciones 3.2, 4.6-4.7, 6, 16.5-16.6, 21.2-21.3 del requerimiento.txt

---

## 1. Inventario Flutter vs Requerimientos por Rol

### 1.1 Preventa (Vendedor Móvil)

| Funcionalidad Requerida | Screen/Provider | Estado | Brecha |
|------------------------|-----------------|--------|--------|
| Login | `auth/` | ✅ | — |
| Consultar inventario tiempo real | `preventa_home_screen.dart` | ⚠️ | Existe pero no muestra bultos/unidades |
| Levantar pedidos | `orders/create_order_screen.dart` | ⚠️ | Falta: tipo contado/crédito, selección nivel precio |
| Pedido al contado | `orders/checkout_screen.dart` | ⚠️ | No diferencia tipo formalmente |
| Pedido al crédito | ❌ | ❌ | No existe flujo de crédito que genere CxC |
| Aplicar precios según permiso | ❌ | ❌ | No hay selector de nivel de precio (1-5) |
| Catálogo de productos | `products/` | ✅ | — |

### 1.2 Rutero (Entrega y Cobro)

| Funcionalidad Requerida | Screen/Provider | Estado | Brecha |
|------------------------|-----------------|--------|--------|
| Login | `auth/` | ✅ | — |
| Ver inventario asignado | `rutero_home_screen.dart` | ⚠️ | Existe pero sin bultos/unidades |
| Pedidos por entregar | `route/delivery_list_screen.dart` | ✅ | — |
| Detalle de parada | `route/stop_details_screen.dart` | ✅ | — |
| Cobrar | `preventa_dashboard/cobranza_screen.dart` | ⚠️ | Existe pero no vincula con CxC del backend |
| Cierre de caja | `home/day_closing_screen.dart` | ⚠️ | Existe UI pero no persiste en backend |
| Registrar devolución | ❌ | ❌ | No existe screen ni repositorio |
| Cartera de clientes | `route/client_portfolio_screen.dart` | ✅ | — |
| Agregar cliente | `route/add_client_screen.dart` | ✅ | — |

### 1.3 Bodeguero (Operación Bodega desde móvil — opcional)

| Funcionalidad Requerida | Screen | Estado | Brecha |
|------------------------|--------|--------|--------|
| Dashboard bodega | `bodega_dashboard/bodega_screen.dart` | ✅ | — |
| Preparación pedido | `bodega_dashboard/order_preparation_screen.dart` | ⚠️ | Existe pero sin bultos/unidades |
| Aprobación | `bodega_dashboard/bodeguero_approval_screen.dart` | ✅ | — |
| Ayudante dashboard | `bodega_dashboard/ayudante_dashboard_screen.dart` | ✅ | — |

---

## 2. Detalle de Brechas por Funcionalidad

### 2.1 Bultos y Unidades en Inventario Preventa (B1)

**Estado actual:**
- `Product` model: tiene `stock` como int simple
- `preventa_home_screen.dart`: muestra "Stock: X" numérico

**Requerimiento:**
- Mostrar: "5 bultos + 10 unidades"
- En pedido: seleccionar cantidad en bultos o unidades

**Cambios necesarios:**
1. **Modelo `Product`**: agregar `unitsPerBulk`, `stockBulks`, `stockUnits`
2. **UI de catálogo**: mostrar dos columnas/badges "Bultos: X | Unidades: Y"
3. **UI de crear pedido**: Toggle "¿Pedir en bultos o unidades?" con conversión automática
4. **Provider**: recalcular totales según presentación seleccionada

### 2.2 Tipo de Pedido: Contado vs Crédito (requerimiento 6.3)

**Estado actual:**
- `Order` model tiene `status` pero no `paymentType`
- `create_order_screen.dart` no pregunta tipo de pago

**Cambios necesarios:**
1. **Modelo `Order`**: agregar `paymentType` enum (contado, credito)
2. **UI crear pedido**: Radio buttons "Contado / Crédito" 
3. **Lógica**: Si crédito → enviar al backend para que genere CxC automáticamente
4. **Validación**: Solo roles con permiso pueden crear pedidos a crédito

### 2.3 Selección de Precio (1-5) (requerimiento 11)

**Estado actual:**
- `Product` model tiene `salePrice` pero no expone price1-price5
- No hay selector de nivel de precio en el flujo de pedido

**Cambios necesarios:**
1. **Modelo `Product`**: agregar `price1` a `price5`
2. **UI crear pedido**: Dropdown de nivel de precio
3. **Regla**: Precio 1 = default, Precio 2-3 = preventa puede seleccionar, Precio 4-5 = placeholder "Requiere autorización" (NO inventar el flujo)
4. **Cálculo**: Al seleccionar nivel, recalcular precio unitario y total

### 2.4 Devoluciones del Rutero (B7)

**Estado actual:** No existe nada.

**Cambios necesarios:**
1. **Modelo `Return`** (nuevo, con Freezed):
```dart
@freezed
class Return with _$Return {
  const factory Return({
    required String id,
    required String orderId,
    required String storeId,
    required String ruteroId,
    required List<ReturnItem> items,
    required DateTime createdAt,
  }) = _Return;
}

@freezed
class ReturnItem with _$ReturnItem {
  const factory ReturnItem({
    required String productId,
    required String productName,
    required int quantityBulks,
    required int quantityUnits,
  }) = _ReturnItem;
}
```

2. **Screen `return_screen.dart`** (nuevo):
   - Seleccionar pedido entregado
   - Seleccionar productos a devolver
   - Ingresar cantidades (bultos + unidades)
   - Confirmar devolución
   - Enqueue al backend via SyncEngine

3. **Repository `returns_repository.dart`** (nuevo):
   - `createReturn()` — guarda local + encola POST
   - `getReturns()` — desde BD local

4. **Provider `returns_provider.dart`** (nuevo)

### 2.5 Cobros Vinculados a CxC (B9)

**Estado actual:**
- `cobranza_screen.dart` existe (10KB) con UI de cobro
- `collection_provider.dart` existe con estado básico
- `CollectionReceipt` model existe
- Pero NO se conecta con `accounts_receivable` del backend

**Cambios necesarios:**
1. **Repository `collections_repository.dart`**: 
   - Agregar `createCollection()` que envíe POST a `/api/collections`
   - El backend debe: crear cobro + actualizar `remaining_amount` de la CxC
2. **Provider**: 
   - Cargar CxC pendientes del cliente actual
   - Mostrar saldo pendiente antes de cobrar
3. **UI**: 
   - Mostrar lista de CxC pendientes por cliente
   - Al cobrar: seleccionar CxC, monto, método de pago
   - Recibo con detalle de abono

### 2.6 Cierre de Caja Persistido (B10)

**Estado actual:**
- `day_closing_screen.dart` calcula totales localmente
- `DailyClosing` model tiene: totalSales, totalCollections, totalReturns, cashTotal
- `closing_provider.dart` agrupa datos pero NO envía al backend

**Cambios necesarios:**
1. **Repository**: `recordDailyClosing()` ya existe pero encola genéricamente. Necesita un endpoint backend dedicado
2. **Backend**: tabla `daily_closings` + módulo NestJS
3. **Nota**: NO inventar estructura detallada del cierre (sección 14.4 del requerimiento). Solo persistir los campos que ya existen en el modelo

### 2.7 Realtime: Escuchar Eventos de Inventario (B5)

**Estado actual:**
- `sync_engine.dart` maneja cola offline pero no escucha eventos entrantes
- No hay listener de Socket.IO para actualizaciones push

**Cambios necesarios:**
1. **Service `realtime_listener.dart`** (nuevo):
   - Conexión Socket.IO al backend
   - Escuchar: `INVENTORY_UPDATE`, `ORDER_STATUS_CHANGE`, `NEW_ORDER`
   - Al recibir: actualizar `LocalDatabase` y notificar providers
2. **Integración con providers**:
   - `products_provider`: invalidar cache cuando llega `INVENTORY_UPDATE`
   - `route_provider`: actualizar cuando llega `ORDER_STATUS_CHANGE`

---

## 3. Archivos Flutter a Crear

| Tipo | Archivo | Propósito |
|------|---------|-----------|
| **Model** | `domain/models/return_model.dart` | Modelo de devolución con Freezed |
| **Model** | `domain/models/account_receivable.dart` | Modelo CxC para mostrar en cobros |
| **Repository** | `data/repositories/returns_repository.dart` | CRUD devoluciones offline-first |
| **Repository** | `data/repositories/collections_repository.dart` | Actualizar para vincular con CxC |
| **Provider** | `presentation/providers/returns_provider.dart` | Estado de devoluciones |
| **Screen** | `presentation/screens/rutero_dashboard/route/return_screen.dart` | UI de registro de devolución |
| **Service** | `infrastructure/realtime_listener.dart` | Listener Socket.IO para eventos push |

## 4. Archivos Flutter a Modificar

| Archivo | Cambio |
|---------|--------|
| `domain/models/product.dart` | Agregar: `unitsPerBulk`, `stockBulks`, `stockUnits`, `price1`-`price5` |
| `domain/models/order.dart` | Agregar: `paymentType`, `priceLevel` |
| `presentation/screens/preventa_dashboard/preventa_home_screen.dart` | UI bultos/unidades |
| `presentation/screens/orders/create_order_screen.dart` | Tipo pedido + nivel precio |
| `presentation/screens/orders/new_order_screen.dart` | Mismo |
| `presentation/screens/rutero_dashboard/home/rutero_home_screen.dart` | Inventario en bultos/unidades |
| `presentation/screens/bodega_dashboard/order_preparation_screen.dart` | Requisa bultos→unidades |
| `presentation/providers/products_provider.dart` | Campos nuevos de producto |
| `presentation/providers/collection_provider.dart` | Vincular con CxC |
| `presentation/providers/closing_provider.dart` | Persistir cierre en backend |
| `data/repositories/products_repository.dart` | Mapeo de campos nuevos |
| `data/repositories/orders_repository.dart` | Enviar paymentType y priceLevel |
| `infrastructure/sync_engine.dart` | Integrar con realtime_listener |
| `infrastructure/local_database.dart` | Agregar tabla local `returns` |
