# Mapa API del Móvil

Fecha de corte: 2026-04-02

## 1. Auth

- `POST /auth/login`
  - uso: iniciar sesión
  - archivo: `lib/features/auth/data/auth_repository.dart`
- `POST /auth/refresh`
  - uso: renovar tokens
  - archivo: `lib/features/auth/data/auth_repository.dart`
- `GET /auth/profile`
  - uso: refrescar perfil actual
  - archivo: `lib/features/auth/data/auth_repository.dart`

## 2. Home

- `GET /users/:id/stores`
  - uso: cargar tiendas asignadas y cachearlas localmente
  - archivo: `lib/features/home/data/home_repository.dart`

## 3. Preventa

- `POST /orders`
  - uso: capturar pedido rápido desde calle
  - archivo: `lib/features/orders/data/quick_order_repository.dart`
  - fallback actual: si falla por conectividad, se encola localmente en SQLite

## 4. Catálogo

- `GET /products?storeId=&limit=200&search=`
  - uso: catálogo operativo con búsqueda rápida
  - archivo: `lib/features/catalog/data/catalog_repository.dart`

## 5. Clientes

- `GET /clients?storeId=`
  - uso: cartera móvil por tienda
  - archivo: `lib/features/clients/data/client_portfolio_repository.dart`

## 6. Ruta y entregas

- `GET /routes?storeId=&vendorId=`
  - uso: rutas visibles para la tienda o vendedor
  - archivo: `lib/features/deliveries/data/route_board_repository.dart`
  - fallback actual: si falla por conectividad, usa cache local SQLite
- `GET /pending-deliveries?storeId=&ruteroId=`
  - uso: pedidos pendientes de entrega
  - archivo: `lib/features/deliveries/data/route_board_repository.dart`
  - fallback actual: si falla por conectividad, usa cache local SQLite

## 7. Cobros

- `GET /accounts-receivable?storeId=&pending=true`
  - uso: listar cartera pendiente
  - archivo: `lib/features/collections/data/collections_repository.dart`
  - fallback actual: si falla por conectividad, usa cache local SQLite
- `GET /collections/summary?storeId=&ruteroId=`
  - uso: resumen de cobranza del día
  - archivo: `lib/features/collections/data/collections_repository.dart`
  - fallback actual: si falla por conectividad, usa cache local SQLite
- `POST /accounts-receivable/:id/payments`
  - uso: registrar cobro rápido
  - archivo: `lib/features/collections/data/collections_repository.dart`
  - apoyo local opcional: comprobante PDF liviano vía `lib/core/documents/pdf_receipt_service.dart`
  - fallback actual: si falla por conectividad, se encola localmente en SQLite

## 8. Devoluciones

- `GET /sales/:saleReference?storeId=`
  - uso: buscar ticket para devolución
  - archivo: `lib/features/returns/data/returns_repository.dart`
- `POST /returns`
  - uso: registrar devolución por ticket
  - archivo: `lib/features/returns/data/returns_repository.dart`
  - fallback actual: si falla por conectividad, se encola localmente en SQLite

## 9. Bodega

- `GET /orders?storeId=&status=`
  - uso: tablero por estado
  - archivo: `lib/features/warehouse/data/warehouse_repository.dart`
- `GET /orders/:id`
  - uso: detalle de picking con `presentation` y `unitsPerBulk`
  - archivo: `lib/features/warehouse/data/warehouse_repository.dart`
- `PATCH /orders/:id/status`
  - uso: mover estado del pedido
  - archivo: `lib/features/warehouse/data/warehouse_repository.dart`
- `GET /users?storeId=`
  - uso: cargar ruteros/vendedores para asignar carga a camión
  - archivo: `lib/features/warehouse/data/warehouse_repository.dart`

## 9.5 Comprobante PDF opcional

- no depende de endpoint nuevo
- se construye con datos ya disponibles del flujo
- se usa en:
  - preventa guardada
  - cobro guardado
- archivo:
  - `lib/core/documents/pdf_receipt_service.dart`

## 10. Realtime y cache local

- `Socket.IO /events`
  - eventos: `NEW_ORDER`, `ORDER_STATUS_CHANGE`, `INVENTORY_TRANSFER`
  - archivos:
    - `lib/core/realtime/websocket_service.dart`
    - `lib/core/realtime/realtime_controller.dart`
    - `lib/core/realtime/realtime_event.dart`
  - impacto actual:
    - refresca mejor `catálogo` cuando cambia inventario
    - refresca mejor `ruta/entregas` cuando cambia orden o transferencia
    - refresca mejor `bodega` cuando entra orden o cambia estado

- `drift`
  - cache de tiendas asignadas
  - cache de catálogo
  - cache de clientes
  - cache de cartera pendiente
  - cache de resumen de cobranza
  - cache de rutas
  - cache de entregas
  - log de eventos realtime
  - cola offline base
  - archivos:
    - `lib/core/database/app_database.dart`
    - `lib/core/database/local_cache_repository.dart`

- `connectivity_plus`
  - monitorea disponibilidad de red para disparar sincronización
  - archivo:
    - `lib/core/network/connectivity_service.dart`

- `sync queue processor`
  - procesa la cola local al haber sesión y red disponible
  - al completar sync, ayuda a forzar recarga online-first de pantallas activas
  - permite reintentar entradas fallidas desde Home
  - archivo:
    - `lib/core/network/sync_queue_processor.dart`

## 11. Estado real de operación offline

Sí existe SQLite local real.

Pero hoy el alcance offline es este:

- sí cachea tiendas asignadas
- sí cachea catálogo
- sí cachea clientes
- sí cachea cartera pendiente
- sí cachea resumen de cobranza
- sí cachea rutas
- sí cachea entregas
- sí conserva sesión
- sí guarda bitácora de eventos realtime
- sí tiene cola offline base
- sí puede encolar pedido rápido si falla la conectividad
- sí puede encolar cobro si falla la conectividad
- sí puede encolar devolución si falla la conectividad
- sí intenta reprocesar la cola al volver la conectividad
- sí vuelve a refrescar pantallas críticas cuando regresa internet o termina la cola
- sí expone pendientes y fallidas por separado en Home para reintento manual
- sí puede restaurar sesión cacheada aunque falle la red al abrir

Todavía no hace de forma integral:

- replay automático integral de pedidos/cobros/devoluciones
- reconciliación automática cuando vuelve la señal

Por eso la app móvil actual es:

- operativa con internet
- resiliente de base
- no todavía offline-first completa
