# Warehouse Web Pendiente

Fecha de corte: 2026-04-01

## Estado en este corte

El backend ya quedó ajustado para soportar mejor el futuro módulo web de bodega:

- `GET /orders/:id` ahora debe exponer `presentation` y `unitsPerBulk`
- `PATCH /orders/:id/status` ya puede aceptar `vendorId`
- al pasar a `CARGADO_CAMION` ya puede emitir `INVENTORY_TRANSFER`

## Lo que no entra en este corte

No se implementó todavía la pantalla React:

- `web/src/pages/store-admin/warehouse/warehouse-dashboard-page.tsx`

## Por qué no entra todavía

No es porque esté roto el backend.

No entra en este corte por estas razones:

1. ya era un alcance nuevo, no un bug escondido del cierre anterior
2. el prompt original de Gemini proponía contratos frontend que no coincidían exactamente con el backend real
3. la prioridad inmediata volvió a Flutter, así que no conviene abrir otro frente grande de React en el mismo corte

## Contrato correcto para cuando se implemente

Cuando se construya la pantalla de bodega en React, debe respetar esto:

- consultar órdenes por `storeId` y `status`
- para cargar camión, usar:
  - `PATCH /orders/:id/status`
  - body: `{ status: 'CARGADO_CAMION', vendorId: 'uuid', updatedBy?: 'uuid' }`
- para el selector de vendedor o rutero, no asumir `/vendors`
  - revisar primero el contrato real de `/users`
  - o crear un endpoint dedicado solo si de verdad hace falta

## Nota importante

Este pendiente no invalida el corte actual de `backend + React`.

Simplemente deja claro que el módulo logístico de bodega web es el siguiente frente funcional, no una regresión del sistema que ya estaba cerrado.
