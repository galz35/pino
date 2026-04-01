# Handoff Para Gemini Local

Este documento esta escrito para que una IA local entienda rapido como esta `pino` sin tener que descubrirlo desde cero.

## 1. Que es este proyecto

`pino` es un sistema MultiTienda con:

- backend NestJS + Fastify + Socket.IO + PostgreSQL
- frontend React + Vite + Tailwind + Radix UI
- una carpeta `flutter/` reservada para la futura app movil

Hoy el alcance realmente implementado es:

- backend REST operativo
- frontend React operativo
- tiempo real por Socket.IO
- Flutter todavia no implementado

## 2. Como debes leer el proyecto

Orden recomendado:

1. `README.md`
2. `docs/00_INDEX.md`
3. `docs/02_MAPA_DEL_PROYECTO.md`
4. `docs/03_ESTRUCTURA_DEL_SISTEMA.md`
5. `docs/06_BASE_DE_DATOS_ESTADO_ACTUAL.md`
6. `docs/07_FLUTTER_ESTRATEGIA_Y_PAUSA.md`
7. `docs/08_VALIDACION_GEMINI_WAREHOUSE.md`
8. `plan/2026-04-01/15-mapa-consumo-api-react.md`
9. `plan/2026-04-01/17-barrido-backend-vs-requerimiento.md`

## 3. Fuentes de verdad

Cuando haya duda, usa este orden:

1. codigo vivo del repo
2. base de datos viva
3. `schema.sql` como DDL base
4. documentacion de `docs/`
5. documentos de `plan/`

Notas importantes:

- `schema.sql` es la base estructural, pero la BD viva ya tiene tablas operativas adicionales.
- la carpeta `plan/` contiene historia, hallazgos y decisiones; `docs/` contiene la referencia consolidada.
- el frontend ya no usa `localhost` hardcodeado; usa configuracion por entorno.
- no asumas que `plan/2026-04-01/03-analisis-gap-flutter.md` describe codigo Flutter existente; hoy es una referencia de estrategia, no de implementacion.

## 4. Donde empezar segun la tarea

Si la tarea es backend:

- entra por `backend/src/app.module.ts`
- luego revisa `backend/src/modules/`
- despues revisa `backend/src/database/database.service.ts`

Si la tarea es frontend:

- entra por `web/src/App.tsx`
- luego `web/src/components/app-layout.tsx`
- luego `web/src/services/api-client.ts`
- despues usa `plan/2026-04-01/15-mapa-consumo-api-react.md`

Si la tarea es Flutter:

- entra por `docs/07_FLUTTER_ESTRATEGIA_Y_PAUSA.md`
- luego `flutter/pubspec.yaml`
- despues `flutter/README.md`
- no supongas que existe dominio/repositorios/features; hoy no existen

Si la tarea es base de datos:

- revisa `backend/src/database/schema.sql`
- revisa `backend/src/database/database.service.ts`
- revisa `docs/06_BASE_DE_DATOS_ESTADO_ACTUAL.md`

## 5. Reglas practicas para tocar el proyecto

- no asumas que Flutter existe; hoy no existe codigo real
- si cambias contratos de API, revisa `plan/2026-04-01/15-mapa-consumo-api-react.md`
- si cambias rutas o guards de roles, revisa `web/src/App.tsx`, `web/src/lib/user-role.ts` y `web/src/lib/redirect-logic.ts`
- si cambias flujos financieros, revisa tanto backend como `web/src/services/finance-service.ts`
- si cambias la BD, actualiza `schema.sql` y `docs/06_BASE_DE_DATOS_ESTADO_ACTUAL.md`

## 6. Runtime actual

Configuracion base del backend:

- host BD: `127.0.0.1`
- puerto BD: `5432`
- base: `multitienda_db`
- puerto backend: `3035`
- prefijo API: `/api`

Configuracion base del frontend:

- basename: `/dev`
- API base publica: `/api-dev`
- socket path publico: `/api-dev/socket.io`
- namespace socket: `/events`

## 7. Estado funcional actual

Este corte deja fuerte:

- autenticacion JWT
- roles y redirects
- POS web
- caja
- catalogo
- inventario
- pedidos y despacho
- vendedores, rutas, visitas y cobros
- cuentas por cobrar
- cuentas por pagar
- facturas de proveedor
- autorizaciones
- sync y realtime

Pendiente deliberado:

- Flutter
- integraciones fisicas de hardware
