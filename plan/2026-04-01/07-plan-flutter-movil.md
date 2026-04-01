# 07 — Plan de Implementación: Flutter Móvil

**Referencia:** Brechas del archivo `03-analisis-gap-flutter.md`

---

## 1. Archivos Nuevos a Crear

### 1.1 Modelos Nuevos

#### `domain/models/return_model.dart`
```dart
@freezed
class ReturnRecord with _$ReturnRecord {
  const factory ReturnRecord({
    required String id,
    required String orderId,
    required String storeId,
    required String ruteroId,
    @Default('') String notes,
    @Default(0.0) double total,
    required List<ReturnItem> items,
    required DateTime createdAt,
  }) = _ReturnRecord;
  factory ReturnRecord.fromJson(Map<String, dynamic> json) => _$ReturnRecordFromJson(json);
}

@freezed
class ReturnItem with _$ReturnItem {
  const factory ReturnItem({
    required String productId,
    @Default('') String productName,
    @Default(0) int quantityBulks,
    @Default(0) int quantityUnits,
    @Default(0.0) double unitPrice,
    @Default(0.0) double subtotal,
  }) = _ReturnItem;
  factory ReturnItem.fromJson(Map<String, dynamic> json) => _$ReturnItemFromJson(json);
}
```

#### `domain/models/account_receivable.dart`
```dart
@freezed
class AccountReceivable with _$AccountReceivable {
  const factory AccountReceivable({
    required String id,
    required String storeId,
    required String clientId,
    @Default('') String clientName,
    String? orderId,
    required double totalAmount,
    required double remainingAmount,
    @Default('') String description,
    @Default('PENDING') String status,
    required DateTime createdAt,
  }) = _AccountReceivable;
  factory AccountReceivable.fromJson(Map<String, dynamic> json) => _$AccountReceivableFromJson(json);
}
```

---

### 1.2 Repositorios Nuevos

#### `data/repositories/returns_repository.dart`
```dart
class ReturnsRepository {
  final LocalDatabase _localDb;
  ReturnsRepository(this._localDb);

  Future<void> createReturn(ReturnRecord returnRecord) async {
    final json = returnRecord.toJson();
    await _localDb.upsert('returns', returnRecord.id, json, extraColumns: {
      'store_id': returnRecord.storeId,
      'order_id': returnRecord.orderId,
      'rutero_id': returnRecord.ruteroId,
      'synced': 0,
    });
    await _localDb.enqueue('POST', '/returns', body: json);
  }

  Future<List<ReturnRecord>> getReturns() async {
    final rows = await _localDb.getAll('returns', orderBy: 'created_at DESC');
    return rows.map((json) => ReturnRecord.fromJson(json)).toList();
  }
}
```

#### `data/repositories/accounts_receivable_repository.dart`
```dart
class AccountsReceivableRepository {
  final ApiClient _api;
  AccountsReceivableRepository(this._api);

  Future<List<AccountReceivable>> getPending(String storeId, {String? clientId}) async {
    final params = {'storeId': storeId, 'pending': 'true'};
    if (clientId != null) params['clientId'] = clientId;
    final response = await _api.get('/accounts-receivable', queryParams: params);
    return (response as List).map((j) => AccountReceivable.fromJson(j)).toList();
  }
}
```

---

### 1.3 Providers Nuevos

#### `presentation/providers/returns_provider.dart`
```dart
@riverpod
class ReturnsNotifier extends _$ReturnsNotifier {
  @override
  FutureOr<List<ReturnRecord>> build() async {
    final repo = ref.read(returnsRepositoryProvider);
    return repo.getReturns();
  }

  Future<void> createReturn(ReturnRecord record) async {
    final repo = ref.read(returnsRepositoryProvider);
    await repo.createReturn(record);
    ref.invalidateSelf();
  }
}
```

#### `presentation/providers/accounts_receivable_provider.dart`
```dart
@riverpod
class AccountsReceivableNotifier extends _$AccountsReceivableNotifier {
  @override
  FutureOr<List<AccountReceivable>> build(String storeId, {String? clientId}) async {
    final repo = ref.read(accountsReceivableRepositoryProvider);
    return repo.getPending(storeId, clientId: clientId);
  }
}
```

---

### 1.4 Screens Nuevos

#### `presentation/screens/rutero_dashboard/route/return_screen.dart`

**Flujo de la UI:**
1. Seleccionar pedido (de los entregados)
2. Mostrar items del pedido
3. Para cada item: input de cantidad a devolver
   - Campo "Bultos" + Campo "Unidades"
   - Mostrar conversión: "2 bultos = 40 unidades"
4. Campo de notas (opcional)
5. Botón "Registrar Devolución"
6. Confirmación con resumen
7. Guardar local + enqueue al backend

**Widgets clave:**
- `ReturnItemRow`: producto + inputs de bultos/unidades
- `ReturnSummarySheet`: bottom sheet con resumen
- `ReturnConfirmDialog`: AlertDialog de confirmación

---

### 1.5 Servicio Realtime

#### `infrastructure/realtime_listener.dart`
```dart
class RealtimeListener {
  late final IO.Socket _socket;
  final LocalDatabase _localDb;
  
  RealtimeListener(this._localDb);

  void connect(String serverUrl, String token) {
    _socket = IO.io(serverUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .setAuth({'token': token})
      .build());

    _socket.on('INVENTORY_UPDATE', (data) {
      // Actualizar producto en BD local
      _localDb.upsert('products', data['productId'], data);
    });

    _socket.on('ORDER_STATUS_CHANGE', (data) {
      // Actualizar pedido en BD local
      _localDb.upsert('orders', data['orderId'], data);
    });

    _socket.on('PRODUCT_CREATED', (data) {
      _localDb.upsert('products', data['id'], data);
    });

    _socket.on('PRODUCT_UPDATED', (data) {
      _localDb.upsert('products', data['id'], data);
    });
  }

  void disconnect() {
    _socket.disconnect();
  }
}
```

---

## 2. Archivos Existentes a Modificar

### 2.1 Modelo Product — Bultos, Unidades, Precios

**Archivo:** `domain/models/product.dart`

**Agregar campos:**
```dart
@Default(1) int unitsPerBulk,
@Default(0) int stockBulks,
@Default(0) int stockUnits,
@Default(0.0) double price1,
@Default(0.0) double price2,
@Default(0.0) double price3,
@Default(0.0) double price4,
@Default(0.0) double price5,
```

**Agregar método helper:**
```dart
double getPriceByLevel(int level) {
  switch (level) {
    case 1: return price1;
    case 2: return price2;
    case 3: return price3;
    case 4: return price4;
    case 5: return price5;
    default: return price1;
  }
}

String get stockDisplay => '$stockBulks bultos + $stockUnits unidades';
```

---

### 2.2 Modelo Order — Tipo de Pago y Nivel Precio

**Archivo:** `domain/models/order.dart`

**Agregar campos:**
```dart
@Default('CONTADO') String paymentType,  // CONTADO | CREDITO
@Default(1) int priceLevel,              // 1-5
```

---

### 2.3 Preventa Home Screen — UI Bultos/Unidades

**Archivo:** `presentation/screens/preventa_dashboard/preventa_home_screen.dart`

**Cambios:**
- En lista de productos: reemplazar `Stock: ${product.stock}` por widget con dos badges:
  ```
  [📦 5 bultos] [📋 10 unidades]
  ```
- En búsqueda: seguir buscando por nombre/barcode

---

### 2.4 Create Order Screen — Tipo Pago + Precio

**Archivo:** `presentation/screens/orders/create_order_screen.dart`

**Cambios:**
1. Agregar `SegmentedButton` para seleccionar tipo: Contado / Crédito
2. Agregar `DropdownButton` para nivel de precio (1-5)
   - Niveles 1-3: habilitados siempre
   - Niveles 4-5: mostrar pero con candado "Requiere autorización"
3. Al seleccionar producto: usar `product.getPriceByLevel(selectedLevel)`
4. Input de cantidad: toggle "Bultos / Unidades" con conversión automática

---

### 2.5 Rutero Home Screen — Inventario con Bultos/Unidades

**Archivo:** `presentation/screens/rutero_dashboard/home/rutero_home_screen.dart`

**Cambios:**
- En la sección de inventario asignado: mostrar `bultos + unidades` separado
- En cards de producto: dos columnas con íconos

---

### 2.6 Order Preparation Screen — Requisa Bultos→Unidades

**Archivo:** `presentation/screens/bodega_dashboard/order_preparation_screen.dart`

**Cambios:**
- Dividir vista en dos secciones según requerimiento:
  - **Sección 1 "BULTOS":** Lista de productos con cantidad en bultos
  - **Sección 2 "UNIDADES":** Lista de productos con cantidad en unidades
- Checkbox por item para marcar preparado
- Subtotales por sección

---

### 2.7 Collection Provider — Vincular con CxC

**Archivo:** `presentation/providers/collection_provider.dart`

**Cambios:**
- Antes de cobrar: cargar CxC pendientes del cliente desde API
- Al crear cobro: enviar `accountId` para vincular
- Mostrar saldo pendiente tras cobro

---

### 2.8 Closing Provider — Persistir en Backend

**Archivo:** `presentation/providers/closing_provider.dart`

**Cambios:**
- En método de cierre: enqueue POST a `/daily-closings`
- Incluir todos los campos del modelo DailyClosing existente

---

### 2.9 Local Database — Tabla Returns

**Archivo:** `infrastructure/local_database.dart`

**Agregar tabla:**
```dart
await db.execute('''
  CREATE TABLE IF NOT EXISTS returns (
    id TEXT PRIMARY KEY,
    data TEXT NOT NULL,
    store_id TEXT,
    order_id TEXT,
    rutero_id TEXT,
    synced INTEGER DEFAULT 0,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
  )
''');
```

---

### 2.10 Sync Engine — Integrar Realtime Listener

**Archivo:** `infrastructure/sync_engine.dart`

**Cambios:**
- En `start()`: crear instancia de `RealtimeListener` y conectar
- En `stop()`: desconectar listener
- Cuando llega evento realtime: invalidar cache local del recurso

---

## 3. Regenerar Código

Después de todas las modificaciones a modelos Freezed:
```bash
dart run build_runner build --delete-conflicting-outputs
```

Archivos que se regenerarán:
- `product.freezed.dart` / `product.g.dart`
- `order.freezed.dart` / `order.g.dart`
- `return_model.freezed.dart` / `return_model.g.dart`
- `account_receivable.freezed.dart` / `account_receivable.g.dart`
- Todos los providers con `@riverpod`

---

## 4. Orden de Implementación Flutter

1. **Modelos** — Product (campos nuevos) + Order (campos nuevos) + Return (nuevo) + AccountReceivable (nuevo)
2. **build_runner** — Regenerar freezed/g.dart
3. **LocalDatabase** — Agregar tabla returns
4. **Repositorios** — returns_repository + accounts_receivable_repository + actualizar collections
5. **Providers** — returns_provider + accounts_receivable_provider + actualizar collection/closing
6. **RealtimeListener** — Nuevo servicio Socket.IO
7. **SyncEngine** — Integrar realtime
8. **Screens Preventa** — Bultos/unidades + tipo pedido + nivel precio
9. **Screens Rutero** — Return screen + cobros vinculados + cierre persistido + inventario bultos/unidades
10. **Screens Bodega** — Preparación con requisa bultos→unidades
