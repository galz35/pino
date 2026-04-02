# Mapa Del Proyecto

## 1. Raiz del repositorio

Directorios principales:

- `backend/`: API REST, logica de negocio, websocket y acceso a PostgreSQL
- `web/`: SPA React para POS, administracion y operacion comercial
- `flutter/`: app móvil Flutter para operación rápida de calle y bodega
- `plan/`: bitacora de analisis, hallazgos, decisiones y checklist de avance
- `docs/`: referencia consolidada de arquitectura y operacion
- `manual_update_dev.sh`: script versionado para actualizar backend y publicar React manualmente

Script operativo local del VPS:

- `/root/ipino.sh`: wrapper manual para ejecutar el update del repo sin entrar a la carpeta

## 2. Mapa de backend

Punto de entrada:

- `backend/src/main.ts`
- `backend/src/app.module.ts`

Capa de base de datos:

- `backend/src/database/database.module.ts`
- `backend/src/database/database.service.ts`
- `backend/src/database/schema.sql`

Modulos de negocio actuales: 31

Principales dominios:

- auth
- users
- stores
- chains
- products
- departments
- sales
- inventory
- cash-shifts
- clients
- orders
- suppliers
- sync
- authorizations
- zones
- licenses
- invoices
- store-zones
- visit-logs
- vendor-inventories
- accounts-receivable
- pending-deliveries
- routes
- pending-orders
- returns
- collections
- accounts-payable
- daily-closings
- errors

Infra compartida:

- `backend/src/common/events.module.ts`
- `backend/src/common/gateways/events.gateway.ts`
- `backend/src/common/guards/`

## 3. Mapa de frontend web

Punto de entrada:

- `web/src/main.tsx`
- `web/src/App.tsx`

Numeros actuales:

- paginas: 53
- componentes: 78
- componentes `ui/`: 36

Capas clave:

- `web/src/pages/`: pantallas por dominio
- `web/src/components/`: UI reusable y layouts
- `web/src/contexts/`: auth y POS
- `web/src/hooks/`: hooks de red, timeout y realtime
- `web/src/services/`: cliente API y dominios financieros
- `web/src/lib/`: runtime config, roles, sync, alerts y utilidades
- `web/src/types/`: tipos base del frontend

Pantallas grandes:

- `pages/master-admin/`
- `pages/store-admin/`
- `pages/store-admin/vendors/`
- `pages/store-admin/products/`
- `pages/store-admin/suppliers/`
- `pages/store-admin/inventory/`

Archivos clave para entender la app:

- `web/src/App.tsx`
- `web/src/components/app-layout.tsx`
- `web/src/components/app-header.tsx`
- `web/src/services/api-client.ts`
- `web/src/services/finance-service.ts`
- `web/src/lib/runtime-config.ts`
- `web/src/lib/user-role.ts`
- `web/src/lib/redirect-logic.ts`
- `web/src/hooks/use-real-time-events.ts`

## 4. Mapa de documentacion

Referencia consolidada:

- `docs/`

Historia del proyecto:

- `plan/2026-04-01/`

Documentos mas importantes del historial:

- `12-checklist-avance.md`
- `14-barrido-estructura-react.md`
- `15-mapa-consumo-api-react.md`
- `17-barrido-backend-vs-requerimiento.md`

Documento consolidado para leer cumplimiento real:

- `docs/12_CUMPLIMIENTO_REQUERIMIENTO_2026-04-02.md`

## 5. Mapa de despliegue logico

Backend:

- servicio Node/NestJS en puerto `3035`
- API publica esperada por frontend: `/api-dev`
- socket publico esperado: `/api-dev/socket.io`

Frontend:

- SPA bajo basename `/dev`
- publicación manual desde `manual_update_dev.sh`
- wrapper local disponible en `/root/ipino.sh`

Base de datos:

- PostgreSQL en Docker
- contenedor: `postgres_alacaja`
- BD: `multitienda_db`

## 6. Mapa Flutter

Punto de entrada:

- `flutter/lib/main.dart`
- `flutter/lib/app/app.dart`

Capas clave:

- `flutter/lib/app/`: shell, router y tema
- `flutter/lib/core/`: config, red, storage, realtime y base local
- `flutter/lib/features/`: auth, home, catalog, clients, orders, deliveries, collections, returns, warehouse y startup

Documentación móvil:

- `flutter/docs/00_INDEX.md`
- `flutter/docs/02_MAPA_MODULOS_Y_FLUJOS.md`
- `flutter/docs/03_MAPA_API_MOVIL.md`
- `flutter/docs/04_ALCANCE_ACTUAL_100.md`
- `flutter/docs/05_PDF_FACTURA_MOVIL_Y_DISPOSITIVOS_BAJA_GAMA.md`

Persistencia local Flutter hoy:

- SQLite real vía `drift`
- cache de tiendas asignadas
- cache de catálogo
- cache de clientes
- cache de cartera pendiente
- cache de resumen de cobranza
- cache de rutas
- cache de entregas
- bitácora local de eventos realtime
- cola offline para pedido, cobro y devolución
- visibilidad en Home de cola pendiente, fallida y operaciones recientes
- refresco automático al volver internet y cuando termina la cola
- refresco por realtime en catálogo, ruta y bodega de la tienda activa

No existe todavía:

- sync offline integral con reconciliación automática
- replay completo de todas las operaciones de negocio
- operación 100% offline en todas las pantallas
