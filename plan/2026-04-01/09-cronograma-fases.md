# 09 — Cronograma por Fases y Entregables

**Referencia:** Sección 20 (Prioridad real de implementación) del requerimiento.txt

---

## Visión General

```
FASE 1: Fundamentos          ███████░░░░░░░░░░░░░  
FASE 2: Flujo Core           ░░░░░░░████████░░░░░░  
FASE 3: Operación Completa   ░░░░░░░░░░░░░░████░░░  
FASE 4: Financiero           ░░░░░░░░░░░░░░░░░███░  
FASE 5: Administración       ░░░░░░░░░░░░░░░░░░░██  
```

---

## FASE 1: Fundamentos — Bultos/Unidades + DB + Realtime Base

**Objetivo:** Establecer la base de datos correcta y el modelo de datos dual (bultos/unidades) en todas las capas.

### Tareas

| # | Tarea | Plataforma | Archivo(s) clave | Dependencia |
|---|-------|-----------|-------------------|-------------|
| 1.1 | Ejecutar migración SQL completa | BD | `schema.sql` ampliado | — |
| 1.2 | Actualizar modelo Product con bultos/unidades | Backend | `products.service.ts` | 1.1 |
| 1.3 | Actualizar modelo Product en React types | React | `types/index.ts` | 1.2 |
| 1.4 | Actualizar modelo Product en Flutter Freezed | Flutter | `product.dart` + regenerar | 1.2 |
| 1.5 | Actualizar UI de productos (tabla) en React | React | `products-page.tsx` | 1.3 |
| 1.6 | Actualizar formulario agregar producto | React | `add-product-page.tsx` | 1.3 |
| 1.7 | Actualizar inventario ajustes (bultos/unidades) | React | `inventory-adjustments-page.tsx` | 1.3 |
| 1.8 | Actualizar catálogo preventa (bultos/unidades) | Flutter | `preventa_home_screen.dart` | 1.4 |
| 1.9 | Expandir EventsGateway con todos los eventos | Backend | `events.gateway.ts` | 1.2 |
| 1.10 | Expandir hook realtime en React | React | `use-real-time-events.ts` | 1.9 |
| 1.11 | Crear RealtimeListener en Flutter | Flutter | `realtime_listener.dart` | 1.9 |

**Entregable:** Productos con bultos/unidades visibles en las 3 plataformas. Eventos realtime base funcionando.

---

## FASE 2: Flujo Core del Pedido — De Preventa a Entrega

**Objetivo:** Implementar el flujo completo: levantamiento → recepción → preparación → alistamiento → carga → entrega.

### Tareas

| # | Tarea | Plataforma | Archivo(s) clave | Dependencia |
|---|-------|-----------|-------------------|-------------|
| 2.1 | Agregar paymentType + priceLevel a Orders | Backend | `orders.service.ts` | F1 |
| 2.2 | Implementar máquina de estados del pedido | Backend | `orders.service.ts` | 2.1 |
| 2.3 | Crear endpoints de transición de estado | Backend | `orders.controller.ts` | 2.2 |
| 2.4 | Emitir ORDER_STATUS_CHANGE en cada transición | Backend | `orders.service.ts` | 2.3 |
| 2.5 | Crear UI de crear pedido con tipo + precio | Flutter | `create_order_screen.dart` | 2.1 |
| 2.6 | Crear pedido al crédito (auto-generar CxC) | Backend | `orders.service.ts` | 2.1 |
| 2.7 | Crear página Preparación de Pedidos | React | `preparation-page.tsx` | 2.3 |
| 2.8 | Crear página Alistamiento/Requisa | React | `picking-page.tsx` | 2.7 |
| 2.9 | Implementar transferencia inventario al cargar camión | Backend | `inventory.service.ts` | 2.3 |
| 2.10 | Actualizar Dispatcher con transferencia real | React | `dispatcher-page.tsx` | 2.9 |
| 2.11 | Crear página Estado de Pedidos (Kanban) | React | `order-status-page.tsx` | 2.3 |
| 2.12 | Actualizar inventario rutero (bultos/unidades) | Backend | `vendor-inventories.service.ts` | F1 |
| 2.13 | Actualizar pantalla inventario rutero en Flutter | Flutter | `rutero_home_screen.dart` | 2.12 |
| 2.14 | Actualizar pending-orders con estados/tipo | React | `pending-orders-page.tsx` | 2.3 |
| 2.15 | Actualizar preparación bodega en Flutter | Flutter | `order_preparation_screen.dart` | 2.8 |
| 2.16 | Actualizar router y sidebar con nuevas secciones | React | `App.tsx`, `app-layout.tsx` | 2.7-2.11 |

**Entregable:** Flujo completo: preventa levanta pedido → bodega lo recibe, prepara, alista → se carga al camión (inventario se transfiere) → rutero ve su inventario → estado visible para admin.

---

## FASE 3: Operación de Campo — Cobros, Devoluciones, Cierre

**Objetivo:** Completar la operación del rutero en campo.

### Tareas

| # | Tarea | Plataforma | Archivo(s) clave | Dependencia |
|---|-------|-----------|-------------------|-------------|
| 3.1 | Crear módulo Returns (backend) | Backend | `modules/returns/` | F2 |
| 3.2 | Crear tabla returns en SQLite local | Flutter | `local_database.dart` | 3.1 |
| 3.3 | Crear modelo ReturnRecord + Freezed | Flutter | `return_model.dart` | 3.1 |
| 3.4 | Crear returns_repository | Flutter | `returns_repository.dart` | 3.3 |
| 3.5 | Crear pantalla de devolución | Flutter | `return_screen.dart` | 3.4 |
| 3.6 | Crear módulo Collections (backend) | Backend | `modules/collections/` | F2 |
| 3.7 | Vincular cobros con CxC existente | Backend | `collections.service.ts` | 3.6 |
| 3.8 | Actualizar cobranza Flutter con CxC | Flutter | `cobranza_screen.dart` + providers | 3.7 |
| 3.9 | Crear módulo DailyClosings (backend) | Backend | `modules/daily-closings/` | 3.6 |
| 3.10 | Persistir cierre de caja del rutero | Flutter | `closing_provider.dart` | 3.9 |
| 3.11 | Crear página Devoluciones en web | React | `returns-page.tsx` | 3.1 |
| 3.12 | Crear página Cuentas por Cobrar en web | React | `receivables-page.tsx` | 3.7 |
| 3.13 | Actualizar vendor-collections en web | React | `vendor-collections-page.tsx` | 3.7 |

**Entregable:** Rutero puede: entregar → cobrar (vinculado a CxC) → registrar devoluciones (vuelven a bodega) → cierre de caja persistido. Admin ve todo en web.

---

## FASE 4: Módulo Financiero

**Objetivo:** Completar el ciclo financiero: CxP, pagos de facturas formales.

### Tareas

| # | Tarea | Plataforma | Archivo(s) clave | Dependencia |
|---|-------|-----------|-------------------|-------------|
| 4.1 | Crear módulo AccountsPayable (backend) | Backend | `modules/accounts-payable/` | F1 |
| 4.2 | Vincular facturas crédito con CxP | Backend | `invoices.service.ts` | 4.1 |
| 4.3 | Crear página Cuentas por Pagar en web | React | `payables-page.tsx` | 4.1 |
| 4.4 | Expandir billing con pago formal | React | `billing-page.tsx` | 4.1 |
| 4.5 | Reportes financieros básicos | React | `reports-page.tsx` | F3 |

**Entregable:** Admin puede: ver CxP vinculadas a facturas de proveedor, registrar pagos, llevar control de obligaciones.

---

## FASE 5: Administración Avanzada

**Objetivo:** Completar funcionalidades de Master Admin y Chain Admin.

### Tareas

| # | Tarea | Plataforma | Archivo(s) clave | Dependencia |
|---|-------|-----------|-------------------|-------------|
| 5.1 | Mejorar Monitor Sync con conexiones activas | Backend + React | `sync-monitor-page.tsx` | F3 |
| 5.2 | Reportes de tienda completos | React | `reports-page.tsx` | F4 |
| 5.3 | Guards por rol en backend | Backend | `guards/` | — |
| 5.4 | Chain Admin: vista multi-tienda | React | Nuevo | 5.3 |

**Entregable:** Master Admin ve estado de sincronización en vivo. Reportes funcionales. Permisos por rol formalizados.

---

## Resumen de Entregables por Fase

| Fase | Entregable Principal | Plataformas |
|------|---------------------|-------------|
| **F1** | Bultos/unidades + Realtime base | BD + Backend + React + Flutter |
| **F2** | Flujo completo pedido → entrega | Backend + React + Flutter |
| **F3** | Cobros + Devoluciones + Cierre caja | Backend + React + Flutter |
| **F4** | CxP + Pagos facturas + Reportes | Backend + React |
| **F5** | Monitor Sync + Chain Admin + Guards | Backend + React |

---

## Dependencias Críticas entre Fases

```
F1 (Fundamentos)
 ├─→ F2 (Flujo Core) 
 │    └─→ F3 (Operación Campo)
 │         └─→ F4 (Financiero)
 │              └─→ F5 (Admin Avanzado)
 └─→ F4 (parcial: CxP no depende de F2/F3 para la tabla)
```

---

## Vacíos que NO se Implementan (por instrucción del requerimiento)

| Vacío | Sección | Razón |
|-------|---------|-------|
| Flujo del Cajero | 4.5 | No definido por cliente |
| Autorización precios 4/5 | 11.3 | No definido quién ni cómo |
| Estructura detallada cierre caja | 14.4 | No definido qué lo compone |
| Reglas contables devoluciones | 15.3 | No definido impacto contable |
| Lógica avanzada de rutas | 13.2 | No definido asignación exacta |
| Soporte offline Flutter | 19.10 | No confirmado por cliente |
| Estados adicionales de pedido | 8 | Solo los 4 confirmados |

Estos quedan como **extensiones futuras** con la arquitectura diseñada para soportarlas sin refactoring.
