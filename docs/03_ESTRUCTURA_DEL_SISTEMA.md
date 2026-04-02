# Estructura Del Sistema

## 1. Arquitectura general

La arquitectura actual es de 4 frentes:

1. frontend web SPA
2. backend REST + websocket
3. base de datos PostgreSQL
4. app móvil Flutter con SQLite local

## 2. Frontend web

Stack:

- React 19
- Vite 8
- React Router
- Tailwind CSS
- Radix UI
- Axios
- Socket.IO client

Responsabilidades del frontend:

- login y redireccion por rol
- POS web y caja
- catalogo e inventario
- despacho y torre de control
- vendedores, rutas, visitas y cobros
- finanzas de tienda
- administracion master

## 3. Backend

Stack:

- NestJS 11
- Fastify
- `pg` para PostgreSQL
- JWT
- Socket.IO
- Swagger

Responsabilidades del backend:

- autenticacion y autorizacion
- reglas de negocio
- persistencia
- validacion de transiciones
- realtime para dashboards
- soporte de sync offline

## 4. Base de datos

Motor:

- PostgreSQL 16

Uso:

- transaccional
- financiero
- inventario
- rutas y visitas
- auditoria y logs operativos

## 5. Roles funcionales

Roles contemplados por el sistema:

- `master-admin`
- `owner`
- `store-admin`
- `cashier`
- `inventory`
- `dispatcher`
- `rutero`
- `vendor`
- `sales-manager`

La normalizacion de roles se hace en:

- `web/src/lib/user-role.ts`
- `web/src/lib/redirect-logic.ts`

## 6. Modulos funcionales

### 6.1 Administracion global

- cadenas
- tiendas
- usuarios
- licencias
- zonas globales
- sub-zonas
- monitor
- sync monitor

### 6.2 Operacion de tienda

- dashboard
- caja
- productos
- departamentos y sub-departamentos
- proveedores
- inventario
- ajustes
- reportes
- settings

### 6.3 Comercial y ruta

- vendedores
- clientes
- visitas
- venta rapida
- pedidos
- despacho
- asignacion de ruta
- ruta de entrega
- cobros

### 6.4 Financiero

- cuentas por cobrar
- cobros
- cuentas por pagar
- facturas de proveedor
- cierre diario

### 6.5 Soporte operativo

- autorizaciones
- errores
- sync
- notificaciones
- websocket
- slow query profiling

## 7. Realtime

El backend emite eventos por Socket.IO desde:

- `backend/src/common/gateways/events.gateway.ts`

Eventos actuales usados por el sistema:

- `NEW_ORDER`
- `NEW_VISIT`
- `PRODUCT_CREATED`
- `PRODUCT_UPDATED`
- `INVENTORY_UPDATE`

El frontend los escucha desde:

- `web/src/hooks/use-real-time-events.ts`
- `web/src/components/app-layout.tsx`

## 8. Sync y modo offline

No hay una app offline completa separada, pero si existe infraestructura para:

- batch sync de operaciones
- heartbeat
- cola de sincronizacion
- logs de sincronizacion
- refresco online-first al volver internet
- separación visible entre cola pendiente y fallida

Archivos clave:

- `web/src/lib/sync-service.ts`
- `backend/src/modules/sync/`

## 9. Flutter

`flutter/` ya es una app móvil real dentro del repo.

Hoy:

- sí hay implementación real
- sí puede tomarse como fuente de verdad del alcance móvil actual
- la app se apoya en:
  - `go_router`
  - `flutter_riverpod`
  - `dio`
  - `drift`
  - `socket_io_client`
- módulos activos:
  - auth
  - home
  - catalog
  - clients
  - orders
  - deliveries
  - collections
  - returns
  - warehouse
- persistencia local actual:
  - `drift` con SQLite real
  - cache de tiendas asignadas
  - cache de catálogo
  - cache de clientes
  - cache de cartera pendiente
  - cache de resumen de cobranza
  - cache de rutas
  - cache de entregas
  - log local de eventos realtime
  - cola offline para pedido, cobro y devolución
- capacidades operativas actuales:
  - Home muestra estado de internet, sync, cola pendiente y cola fallida
  - Home muestra operaciones locales recientes para inspección rápida
  - catálogo, ruta y bodega refrescan por realtime de la tienda activa
  - si falla red, pedido, cobro y devolución pueden quedar en cola local para reintento

Lo que sigue fuera del alcance actual:

- offline completo
- integración de hardware
- reconciliación automática por mala señal
- operación 100% offline en todas las pantallas
