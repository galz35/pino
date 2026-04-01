# 08 — Plan de Sincronización en Tiempo Real

**Referencia:** Sección 5 del requerimiento.txt  
**Condición crítica:** "Los datos entre bodega, preventa y rutero deben reflejarse en tiempo real, sin desfase operativo"

---

## 1. Arquitectura Actual

```
┌──────────┐     HTTP/REST      ┌───────────┐     PostgreSQL     ┌──────┐
│  React   │ ←────────────────→ │  NestJS   │ ←───────────────→  │  BD  │
│  (Web)   │                    │ (Fastify) │                    │      │
└──────────┘                    └───────────┘                    └──────┘
                                      │
                               Socket.IO (solo NEW_ORDER)
                                      │
                                      ▼
                              ┌──────────────┐
                              │   Flutter    │
                              │   (Móvil)    │
                              └──────────────┘
                                      │
                               SyncEngine (cola offline)
                                      │
                              ┌──────────────┐
                              │   SQLite     │
                              │   (Local)    │
                              └──────────────┘
```

**Problemas actuales:**
- Solo se emite `NEW_ORDER` → el resto de los cambios no se propagan
- Flutter NO escucha eventos Socket.IO entrantes
- React tiene hook `use-real-time-events.ts` pero con scope limitado
- No hay mecanismo para que un cambio en web llegue a Flutter y viceversa

---

## 2. Arquitectura Objetivo

```
┌──────────┐                    ┌───────────┐                    ┌──────┐
│  React   │ ←── Socket.IO ──→ │  NestJS   │ ←── SQL ────────→  │  BD  │
│  (Web)   │     (bidirec.)    │ (Fastify) │                    │      │
└──────────┘                    └───────────┘                    └──────┘
                                      │
                               Socket.IO (bidireccional)
                                      │
                              ┌──────────────┐
                              │   Flutter    │
                              │   (Móvil)    │
                              └──────────────┘
                                      │
                         RealtimeListener + SyncEngine
                                      │
                              ┌──────────────┐
                              │   SQLite     │
                              │   (Local)    │
                              └──────────────┘
```

**Flujo completo:**
1. Cambio en cualquier plataforma → llama API REST al backend
2. Backend ejecuta operación en BD
3. Backend emite evento Socket.IO a TODAS las conexiones de la misma tienda
4. React recibe → actualiza UI
5. Flutter recibe → actualiza SQLite local → providers refrescan UI

---

## 3. Catálogo de Eventos Realtime

### 3.1 Eventos de Inventario

| Evento | Trigger | Payload | Quien emite | Quien escucha |
|--------|---------|---------|-------------|---------------|
| `INVENTORY_UPDATE` | adjustStock | `{ storeId, productId, stockBulks, stockUnits, currentStock }` | Backend (Inv.Service) | React + Flutter |
| `INVENTORY_TRANSFER` | transferToRutero | `{ storeId, ruteroId, items: [{productId, bulks, units}] }` | Backend (Inv.Service) | React + Flutter |
| `PRODUCT_CREATED` | products.create | `{ storeId, product: {...} }` | Backend (Prod.Service) | React + Flutter |
| `PRODUCT_UPDATED` | products.update | `{ storeId, product: {...} }` | Backend (Prod.Service) | React + Flutter |

### 3.2 Eventos de Pedidos

| Evento | Trigger | Payload | Quien emite | Quien escucha |
|--------|---------|---------|-------------|---------------|
| `NEW_ORDER` | orders.create | `{ storeId, order: {...} }` | Backend (ya existe) | React + Flutter |
| `ORDER_STATUS_CHANGE` | updateStatus | `{ storeId, orderId, oldStatus, newStatus, updatedBy }` | Backend (Orders.Service) | React + Flutter |

### 3.3 Eventos de Operación

| Evento | Trigger | Payload | Quien emite | Quien escucha |
|--------|---------|---------|-------------|---------------|
| `NEW_RETURN` | returns.create | `{ storeId, returnId, ruteroId, items }` | Backend (Returns.Service) | React (bodega) |
| `NEW_COLLECTION` | collections.create | `{ storeId, collectionId, accountId, amount }` | Backend (Collections.Service) | React (admin) |
| `DAILY_CLOSING_REGISTERED` | closings.create | `{ storeId, ruteroId, date, totals }` | Backend (Closings.Service) | React (admin) |

---

## 4. Implementación Backend — EventsGateway Expandido

### 4.1 Gateway Actual (expandir)

**Archivo:** `common/gateways/events.gateway.ts`

```typescript
@WebSocketGateway({
  cors: { origin: '*' },
  namespace: '/events',
})
export class EventsGateway implements OnGatewayConnection, OnGatewayDisconnection {
  @WebSocketServer()
  server: Server;
  
  private connectedClients = new Map<string, { 
    socketId: string, 
    storeId: string,
    platform: 'web' | 'flutter',
    userId: string 
  }>();

  handleConnection(client: Socket) {
    const storeId = client.handshake.query.storeId as string;
    const platform = client.handshake.query.platform as string;
    const userId = client.handshake.query.userId as string;
    
    if (storeId) {
      client.join(`store:${storeId}`);
      this.connectedClients.set(client.id, { 
        socketId: client.id, storeId, 
        platform: platform as any, userId 
      });
    }
  }

  handleDisconnection(client: Socket) {
    this.connectedClients.delete(client.id);
  }

  // Emitir a toda la tienda
  emitToStore(storeId: string, event: string, payload: any) {
    this.server.to(`store:${storeId}`).emit(event, payload);
  }

  // Para Monitor Sync: estado de conexiones
  getConnectedClients() {
    return Array.from(this.connectedClients.values());
  }
}
```

### 4.2 Integración con Servicios

Cada servicio que necesite emitir realtime:

```typescript
// En InventoryService
constructor(
  private readonly db: DatabaseService,
  private readonly eventsGateway: EventsGateway, // Inyectar
) {}

async adjustStock(dto: ...) {
  const result = await this.db.withTransaction(async (client) => {
    // ... lógica existente ...
    return movement;
  });

  // EMITIR después de la transacción exitosa
  this.eventsGateway.emitToStore(dto.storeId, 'INVENTORY_UPDATE', {
    storeId: dto.storeId,
    productId: dto.productId,
    stockBulks: result.balanceBulks,
    stockUnits: result.balanceUnits,
    currentStock: result.balance,
  });

  return result;
}
```

---

## 5. Implementación React — Listener Expandido

### 5.1 Hook use-real-time-events.ts (expandir)

```typescript
export function useRealTimeEvents(storeId: string) {
  const [socket, setSocket] = useState<Socket | null>(null);

  useEffect(() => {
    const s = io(`${API_URL}/events`, {
      query: { storeId, platform: 'web' },
    });

    s.on('INVENTORY_UPDATE', (data) => {
      // Invalidar queries de productos/inventario
      queryClient.invalidateQueries({ queryKey: ['products', storeId] });
      queryClient.invalidateQueries({ queryKey: ['inventory', storeId] });
    });

    s.on('ORDER_STATUS_CHANGE', (data) => {
      queryClient.invalidateQueries({ queryKey: ['orders', storeId] });
      // Notificación toast
      toast({ title: `Pedido ${data.orderId} → ${data.newStatus}` });
    });

    s.on('NEW_ORDER', (data) => {
      queryClient.invalidateQueries({ queryKey: ['orders', storeId] });
      toast({ title: 'Nuevo pedido recibido' });
    });

    s.on('NEW_RETURN', (data) => {
      queryClient.invalidateQueries({ queryKey: ['returns', storeId] });
      toast({ title: 'Devolución registrada por rutero' });
    });

    s.on('NEW_COLLECTION', (data) => {
      queryClient.invalidateQueries({ queryKey: ['receivables', storeId] });
    });

    setSocket(s);
    return () => { s.disconnect(); };
  }, [storeId]);

  return socket;
}
```

---

## 6. Implementación Flutter — Realtime Listener

### 6.1 Servicio RealtimeListener

**Archivo:** `infrastructure/realtime_listener.dart`

```dart
class RealtimeListener {
  IO.Socket? _socket;
  final LocalDatabase _localDb;
  final Ref _ref;

  RealtimeListener(this._localDb, this._ref);

  void connect(String serverUrl, String storeId, String userId) {
    _socket = IO.io('$serverUrl/events', 
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .setQuery({'storeId': storeId, 'platform': 'flutter', 'userId': userId})
        .enableAutoConnect()
        .enableReconnection()
        .build()
    );

    _socket!.on('INVENTORY_UPDATE', (data) {
      // Actualizar producto en BD local
      final productId = data['productId'];
      _localDb.updateFields('products', productId, {
        'stockBulks': data['stockBulks'],
        'stockUnits': data['stockUnits'],
        'currentStock': data['currentStock'],
      });
      // Invalidar provider
      _ref.invalidate(productsProvider);
    });

    _socket!.on('ORDER_STATUS_CHANGE', (data) {
      final orderId = data['orderId'];
      _localDb.updateFields('orders', orderId, {
        'status': data['newStatus'],
      });
      _ref.invalidate(ordersProvider);
    });

    _socket!.on('PRODUCT_CREATED', (data) {
      _localDb.upsert('products', data['id'], data);
      _ref.invalidate(productsProvider);
    });

    _socket!.on('PRODUCT_UPDATED', (data) {
      _localDb.upsert('products', data['id'], data);
      _ref.invalidate(productsProvider);
    });

    _socket!.on('INVENTORY_TRANSFER', (data) {
      // Si soy el rutero de esta transferencia, actualizar mi inventario
      if (data['ruteroId'] == userId) {
        _ref.invalidate(vendorInventoryProvider);
      }
    });

    _socket!.onConnect((_) => debugPrint('🔌 Realtime conectado'));
    _socket!.onDisconnect((_) => debugPrint('❌ Realtime desconectado'));
    _socket!.onReconnect((_) => debugPrint('🔄 Realtime reconectado'));
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  bool get isConnected => _socket?.connected ?? false;
}
```

### 6.2 Integración con SyncEngine

```dart
// En sync_engine.dart - método start()
void start(String serverUrl, String storeId, String userId) {
  // ... cola offline existente ...
  
  // NUEVO: iniciar listener realtime
  _realtimeListener = RealtimeListener(_localDb, _ref);
  _realtimeListener.connect(serverUrl, storeId, userId);
}
```

---

## 7. Monitor Sync para Master Admin (B11)

### 7.1 Backend — Endpoint de estado

```typescript
@Get('connections')
getConnections() {
  return this.eventsGateway.getConnectedClients();
}
```

### 7.2 React — Sync Monitor Page mejorada

Mostrar por tienda:
- Dispositivos conectados (web/flutter)
- Último evento emitido
- Indicador online/offline por dispositivo
- Conteo de operaciones pendientes de sync

---

## 8. Diagrama de Flujo Crítico: Tiempo Real

```
PREVENTA (Flutter)                 BACKEND (NestJS)                  BODEGA (React Web)
       │                                 │                                  │
       │  POST /orders                   │                                  │
       │ ──────────────────────────────→  │                                  │
       │                                 │  INSERT orders + items            │
       │                                 │  ──────────────→ BD              │
       │                                 │                                  │
       │                                 │  emit('NEW_ORDER')               │
       │                                 │ ─────────────────────────────→   │
       │                                 │                                  │  ← UI se actualiza
       │                                 │                                  │
       │                                 │  BODEGUERO: PATCH /orders/:id/prepare
       │                                 │ ←──────────────────────────────  │
       │                                 │                                  │
       │                                 │  emit('ORDER_STATUS_CHANGE')     │
       │  ← UI se actualiza             │ ─────────────────────────────→   │
       │                                 │                                  │
```

---

## 9. Consideraciones de Performance

1. **Rooms de Socket.IO por tienda:** Cada socket se une a `store:{storeId}` → solo recibe eventos de su tienda
2. **Debounce en React:** No re-renderizar por cada evento, usar `queryClient.invalidateQueries` que tiene cache inteligente
3. **Batch en Flutter:** Si llegan muchos eventos seguidos, agrupar actualizaciones a BD local con debounce de 100ms
4. **Reconexión automática:** Socket.IO ya tiene retry built-in. En Flutter configurar `enableReconnection()`
5. **Heartbeat:** Socket.IO maneja ping/pong automáticamente para detectar desconexiones
