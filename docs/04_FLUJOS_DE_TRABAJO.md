# Flujos De Trabajo

## 1. Flujo de trabajo tecnico

### 1.1 Cuando se toca backend

Secuencia recomendada:

1. revisar modulo en `backend/src/modules/`
2. revisar tablas implicadas en `schema.sql` y BD viva
3. ajustar servicio y controlador
4. validar build de backend
5. revisar impacto en `plan/2026-04-01/15-mapa-consumo-api-react.md`
6. actualizar documentacion si cambia contrato o flujo

### 1.2 Cuando se toca frontend

Secuencia recomendada:

1. revisar ruta en `web/src/App.tsx`
2. revisar layout y roles
3. revisar pantalla o componente consumidor
4. revisar `api-client.ts` o `finance-service.ts`
5. validar build de frontend
6. actualizar el mapa API si cambian endpoints

### 1.3 Cuando se toca Flutter

Secuencia recomendada:

1. revisar `flutter/docs/00_INDEX.md`
2. revisar `flutter/lib/app/router/app_router.dart`
3. revisar feature implicada en `flutter/lib/features/`
4. revisar si el dato depende de API en vivo o de cache local
5. validar `flutter analyze`
6. validar `flutter test`
7. actualizar documentación móvil si cambia flujo, API o persistencia local

### 1.4 Cuando se toca base de datos

Secuencia recomendada:

1. cambiar DDL base en `backend/src/database/schema.sql`
2. revisar servicios afectados
3. revisar la BD viva si hay drift
4. actualizar `docs/06_BASE_DE_DATOS_ESTADO_ACTUAL.md`
5. si aplica, validar `consultasql`

## 2. Flujos funcionales del sistema

### 2.1 Login y redireccion

Paso funcional:

1. usuario hace login
2. backend emite JWT
3. frontend normaliza rol
4. frontend redirige a la vista correcta

Archivos clave:

- `backend/src/modules/auth/`
- `web/src/pages/login-page.tsx`
- `web/src/lib/redirect-logic.ts`

### 2.2 Venta POS y caja

Paso funcional:

1. cajero abre turno
2. busca productos
3. selecciona o crea cliente si aplica
4. procesa venta
5. backend registra venta, items y afecta caja

Tablas clave:

- `cash_shifts`
- `sales`
- `sale_items`

Archivos clave:

- `web/src/pages/store-admin/billing/billing-page.tsx`
- `web/src/pages/store-admin/cash-register/cash-register-page.tsx`
- `backend/src/modules/sales/`
- `backend/src/modules/cash-shifts/`

### 2.3 Pedido a credito

Paso funcional:

1. se registra pedido con `paymentType=CREDITO`
2. backend crea pedido
3. backend genera cuenta por cobrar

Tablas clave:

- `orders`
- `order_items`
- `accounts_receivable`

### 2.4 Despacho y entrega

Paso funcional:

1. pedido entra como pendiente
2. despacho lo toma
3. se asigna ruta
4. rutero trabaja la entrega
5. estado del pedido avanza

Tablas clave:

- `pending_orders`
- `pending_deliveries`
- `routes`
- `orders`

Archivos clave:

- `backend/src/modules/pending-orders/`
- `backend/src/modules/pending-deliveries/`
- `backend/src/modules/orders/`
- `web/src/pages/store-admin/dispatcher/dispatcher-page.tsx`
- `web/src/pages/store-admin/delivery-route/delivery-route-page.tsx`

### 2.5 Flujo vendedor y ruta comercial

Paso funcional:

1. se gestionan vendedores y clientes
2. se registran visitas
3. se puede vender rapido o crear pedido
4. se pueden cobrar cuentas pendientes

Tablas clave:

- `clients`
- `visit_logs`
- `vendor_inventories`
- `accounts_receivable`
- `collections`
- `routes`

### 2.6 Factura de proveedor y cuenta por pagar

Paso funcional:

1. se registra factura de proveedor
2. si es a credito, se genera cuenta por pagar
3. se registran pagos parciales o totales

Tablas clave:

- `suppliers`
- `invoices`
- `invoice_items`
- `accounts_payable`
- `payable_payments`

Archivos clave:

- `web/src/pages/store-admin/suppliers/supplier-invoices-page.tsx`
- `backend/src/modules/invoices/`
- `backend/src/modules/accounts-payable/`

### 2.7 Autorizaciones administrativas

Paso funcional:

1. se crea una autorizacion
2. perfiles administrativos la ven
3. pueden aprobar o rechazar

Tablas clave:

- `authorizations`

Archivos clave:

- `web/src/components/global-alert-provider.tsx`
- `web/src/pages/store-admin/authorizations/authorizations-page.tsx`
- `backend/src/modules/authorizations/`

### 2.8 Realtime y notificaciones

Paso funcional:

1. backend emite evento
2. frontend se conecta a `/events`
3. la UI muestra toast o notificacion

Archivos clave:

- `backend/src/common/gateways/events.gateway.ts`
- `web/src/hooks/use-real-time-events.ts`
- `web/src/components/app-layout.tsx`

### 2.9 Slow query profiling

Paso funcional:

1. backend ejecuta query
2. `DatabaseService` mide duracion
3. si `consultasql.activo=true` y supera `umbral_ms`, guarda historial

Tablas clave:

- `consultasql`
- `consultasql_historial`

Archivos clave:

- `backend/src/database/database.service.ts`

### 2.10 Flujo móvil actual

Paso funcional:

1. usuario inicia sesión
2. la app restaura o guarda sesión segura
3. carga tiendas asignadas desde API y las cachea localmente
4. conecta realtime base por Socket.IO
5. entra al módulo móvil según rol
6. intenta trabajar online primero
7. si falla red en captura crítica, encola pedido, cobro o devolución localmente
8. Home deja visible cuántas operaciones siguen pendientes o fallidas
9. cuando vuelve internet, la cola intenta reprocesarse
10. catálogo, ruta y bodega refrescan al volver internet o por realtime de la tienda activa

Persistencia local real hoy:

- cache de tiendas asignadas
- cache de catálogo
- cache de clientes
- cache de cartera pendiente
- cache de resumen de cobranza
- cache de rutas
- cache de entregas
- log local de eventos realtime
- cola offline para pedido, cobro y devolución

Regla importante:

- hoy la app no debe describirse como offline-first completa
- con mala señal aguanta mejor que una app puramente online, pero todavía no resuelve sync total de negocio ni reconciliación integral
