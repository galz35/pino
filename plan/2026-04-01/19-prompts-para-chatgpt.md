# Súper Prompts de Ejecución Final para ChatGPT

Este documento contiene los requerimientos técnicos exactos preparados para que ChatGPT complete los huecos que quedan en el Backend y FrontEnd sin romper nada de lo ya establecido. Su contexto y capacidad de procesamiento de tokens permitirán procesarlos a la perfección.

## 🛠️ PROMPT 1: Parches Críticos del Backend (NestJS)

**Copia y pega lo siguiente en ChatGPT:**

```text
Actúa como Arquitecto Backend NestJS Experto. Estamos estabilizando un sistema de logística ("pino") y me falta cerrar dos huecos quirúrgicos en el contrato del módulo Orders. Nuestro frontend necesita cálculos de bultos/unidades y poder despachar físicamente el camión.

**Tarea Única:** Actualizar `orders.service.ts` y `orders.controller.ts` para cubrir los siguientes contratos.

1. **Expansión del Payload de Productos en el Pedido (GET):**
Actualmente el `findOne` de `OrdersService` o su equivalente que extrae la información de la orden, debe devolver `units_per_bulk` y `presentation` para cada Item dentro de sus resultados. Para lograrlo, haz el `LEFT JOIN products` necesario en la query SQL del detalle y mapea `unitsPerBulk` en la respuesta JSON. El FrontEnd usa esta data para calcular los bultos para el picker o almacenista.

2. **Asignación en Vivo del Camión (PATCH):**
En `orders.controller.ts` el endpoint `PATCH /:id/status` debe aceptar opcionalmente un campo `vendorId: string`. Luego en `OrdersService.updateStatus`, cuando el nuevo `status` sea `'CARGADO_CAMION'`, si mandaron el `vendorId`, primero actualiza `vendor_id = vendorId` en la tabla `orders`. SÓLO ESTO PERMITE cargar un vendedor en caliente desde el andén de bodega sin errores.

3. **Eventos Realtime (Sockets):**
Al momento exacto de procesar la carga al camión en `CARGADO_CAMION`, asegúrate de utilizar o inyectar `EventsGateway` (`emitSyncUpdate`) con un tag tipo `'INVENTORY_TRANSFER'` para que el frontend React parpadee la interface sola sin F5.

Genera SÓLO las porciones modificadas de `orders.controller.ts` y `orders.service.ts`. Usa TypeScript seguro, asume que `DatabaseService` (con parametrización pura tipo `$1, $2`) ya existe.
```

---

## 🎨 PROMPT 2: Creación del Módulo Logístico Bodega (React/Vite)

**Copia y pega lo siguiente en ChatGPT UNA VEZ terminado el prompt 1:**

```text
Actúa como Frontend Tech Lead experto en React, Vite, TailwindCSS y Shadcn UI.
El proyecto "pino" opera con bultos y unidades, y el backend NestJS acaba de actualizarse para devolvernos la conversión de `unitsPerBulk` por cada orden.
 
**Tu Tarea:**
Crea el Módulo Operativo de Bodega: `web/src/pages/store-admin/warehouse/warehouse-dashboard-page.tsx`. Ésta ventana es sagrada. Ignora las pantallas de "despacho de mostrador", aquí haremos Logística Fuerte.

**Reglas de Flujo y Componentes:**
1. **Tablero Principal:** Diseña 4 columnas o pestañas: 
   - `RECIBIDOS` -> `EN PREPARACIÓN` -> `ALISTADOS` -> `CARGADOS`.
   Haz un fetch usando `apiClient.get('/orders', { params: { status: 'X' } })` y carga las órdenes del día en formato de tarjeta (Card).

2. **Acción de Estado:** Pon en cada tarjeta un botón para transicionar de izquierda a derecha llamando a `PATCH /orders/:id/status`.

3. **La Magia del Picking Modal:** Cuando se da click a un botón "Iniciar Preparación", abre un Modal/Sheet. Aquí mostrarás una "Picking List". Para cada item de esa orden, dibuja dinámicamente BULTOS y UNIDADES.
   Ejemplo Lógico: Si `item.quantity` = 15 y el nuevo campo del backend `item.unitsPerBulk` = 6. Muestra grande y claro en la interfaz administrativa: "2 Bultos Cerrados y 3 Unidades Sueltas".

4. **Soporte de Carga a Camión:** Cuando alguien quiere pasar la tarjeta desde `ALISTADO` a `CARGADO_CAMION`, ¡ABRE UN DIÁLOGO FINAL! Debe traer los Vendedores desde `/vendors` y pintar un `<Select>`. Cuando el bodeguero selecciona "Camión de Juan" y da Confirmar, mandarás en el payload de tu PATCH: `{ status: 'CARGADO_CAMION', vendorId: 'uuid-de-juan' }`.

Produce todo en modo DRY (Don't Repeat Yourself), maneja `useToast` para interactividad asíncrona y diseña botones vibrantes que destaquen la experiencia del usuario (Bodeguero con tablet / monitor industrial). 
```

---

## 📱 PROMPT 3: Sincronización Flutter Sockets (Guárdalo para la Fase Móvil)

**Copia y pega este prompt cuando estemos listos para atacar la app móvil:**

```text
Actúa como Arquitecto Flutter + Riverpod. 
En nuestra App de Logística Móvil de entregas callejeras para "pino", vamos a abandonar Firebase Realtime completamente. Nuestro Backend ahora usa NestJS, PostgreSQL y emite eventos sobre `socket.io`.

**Tu Tarea:**
Diseña la clase core y el provider: `WebSocketService` y `inventory_sync_provider.dart`.

1. **Autenticación en Vivo**: El Socket debe inicializarse enviando el Token JWT.
2. **Listeners Básicos**: Que escuche los eventos `INVENTORY_TRANSFER` y `NEW_ORDER`.
3. **Mecánica Riverpod**: Si llega un evento "INVENTORY_TRANSFER", el provider local debe notificar al catálogo *offline-first* para refrescar las cajas reales del camión según los nuevos datos bajados desde MongoDB sin cerrar la aplicación de Flutter y sin causar freeze exceptions.

Dame el esqueleto inicial fuerte para un desarrollador mediano y pon loggers detallados para inspección.
```
