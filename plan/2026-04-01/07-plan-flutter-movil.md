# 07 - Plan de Implementacion: Flutter Movil

Fecha de corte: 2026-04-01

## 1. Decision actual

Flutter queda en pausa por ahora.

La prioridad vigente del producto sigue siendo:

1. backend NestJS
2. React web
3. despliegue y verificacion operativa
4. Flutter despues

## 2. Base tecnica ya preparada

El frente movil ya tiene:

- SDK instalado localmente
- scaffold base en `flutter/`
- stack de paquetes seleccionado

Eso permite reanudar despues sin partir de cero.

## 3. Plan correcto para retomarlo

### Fase 0 - Bootstrap

- reemplazar `lib/main.dart`
- crear `app/`, `core/`, `features/`
- definir runtime config
- definir tema y shell base

### Fase 1 - Auth y sesion

- login
- session store
- secure storage
- refresh token
- guards por rol

### Fase 2 - Networking

- cliente `dio`
- interceptores
- manejo de errores
- servicios base contra `/api-dev`

### Fase 3 - Persistencia local

- `drift` schema
- tablas cache
- tabla de cola offline
- politica de merge

### Fase 4 - Realtime

- socket client
- suscripcion al namespace `/events`
- manejo de `NEW_ORDER`
- manejo de `ORDER_STATUS_CHANGE`
- manejo de `INVENTORY_UPDATE`

### Fase 5 - Features de negocio

Orden recomendado:

1. vendedor/preventa
2. rutero
3. cartera/cobros
4. devoluciones
5. dashboard movil
6. bodega movil opcional

## 4. Reglas para no tropezar despues

- no inventar contratos distintos a backend
- no modelar offline-first complejo antes de tener online-first estable
- no asumir que React y Flutter deben tener exactamente la misma UX
- no construir bodega movil antes de cerrar auth y sync

## 5. Fuente de verdad

La referencia de arquitectura y pausa esta en:

- `docs/07_FLUTTER_ESTRATEGIA_Y_PAUSA.md`
