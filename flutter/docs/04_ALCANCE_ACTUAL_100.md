# Alcance Actual al 100

Fecha de corte: 2026-04-02

## 1. Qué significa 100% aquí

Flutter queda al `100%` dentro del alcance móvil acordado para este corte:

- sesión real
- home rápido por rol
- preventa
- catálogo
- clientes
- ruta y entregas
- cobros
- devoluciones
- bodega
- cache local base
- cache local de tiendas, catálogo, clientes, cartera, resumen de cobranza, rutas y entregas
- realtime base
- comprobante PDF opcional y liviano para pedido/cobro
- fallback a cola local para pedido, cobro y devolución cuando falla la conectividad
- reproceso automático básico de cola al volver internet
- refresco online-first automático al volver internet o vaciar la cola local
- visibilidad de cola pendiente/fallida y reintento manual de fallidas
- refresco de pantallas críticas por eventos realtime de la tienda activa
- restauración de sesión con tolerancia a falla de red

## 2. Qué no se está prometiendo

Este `100%` no significa todavía:

- offline-first completo
- sincronización diferida con reintentos inteligentes
- soporte de impresoras o escáneres físicos
- optimización por modelos específicos de dispositivo

Eso queda como fase 2.

## 3. Validación del corte

- `flutter analyze` -> OK
- `flutter test` -> OK
  Nota: 2 pruebas SQLite de repositorio quedan marcadas como `skip` en este VPS Ubuntu 20.04 por límite de `GLIBC` del asset nativo, no por fallo funcional del código.

## 4. Regla para próximos cambios

Si se agrega una feature nueva, deja de ser “100% del alcance actual” y pasa a ser una ampliación de alcance.
