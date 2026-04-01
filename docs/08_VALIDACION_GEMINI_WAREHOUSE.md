# Validacion de la Propuesta Gemini: Warehouse Dashboard

Fecha de corte: 2026-04-01

## 1. Veredicto corto

La propuesta de Gemini va bien encaminada, pero no esta 100% alineada con el codigo real.

Conclusiones:

- si falta un modulo visual de bodega en React
- si existe la maquina de estados base en backend
- si el backend ya hace la transferencia de inventario al pasar a `CARGADO_CAMION`
- no, hoy no se puede implementar exactamente el flujo propuesto sin ajustar dos contratos backend

## 2. Lo que Gemini acierta

### 2.1 Falta un tablero de bodega en React

En `web/src/App.tsx` no existe una ruta ni una pagina actual para:

- `warehouse`
- `bodega`
- `warehouse-dashboard-page.tsx`

Por tanto, el hueco funcional si existe.

### 2.2 La API ya tiene la maquina de estados principal

Backend real:

- `GET /orders`
- `GET /orders/:id`
- `PATCH /orders/:id/status`
- `PATCH /orders/:id/prepare`
- `PATCH /orders/:id/stage`
- `PATCH /orders/:id/load-truck`
- `PATCH /orders/:id/dispatch`
- `PATCH /orders/:id/deliver`

Estados existentes hoy:

- `RECIBIDO`
- `EN_PREPARACION`
- `ALISTADO`
- `CARGADO_CAMION`
- `EN_ENTREGA`
- `ENTREGADO`
- `DEVUELTO`
- `RECHAZADO`
- `CANCELADO`

### 2.3 El backend ya mueve inventario al cargar al camion

En `backend/src/modules/orders/orders.service.ts`, al pasar a `CARGADO_CAMION` el servicio:

- bloquea la orden en transaccion
- valida la transicion
- descuenta stock de `products`
- incrementa `vendor_inventories`
- registra movimientos en `movements`

Por eso la idea de usar ese estado como punto critico logistico es correcta.

### 2.4 El rol de bodega ya tiene normalizacion

En `web/src/lib/user-role.ts`:

- `warehouse`
- `bodeguero`
- `ayudante-de-bodega`

se normalizan a `inventory`.

Eso permite montar un modulo de bodega dentro del grupo de permisos de inventario sin inventar un sistema de roles nuevo.

## 3. Lo que Gemini sobre-asume y hoy no esta listo

### 3.1 Seleccionar vendedor o rutero al momento de `CARGADO_CAMION`

La propuesta de Gemini pide abrir un modal y mandar algo como:

- `PATCH /orders/:id/status`
- body con `status` y vendedor seleccionado

Eso hoy no existe.

El contrato real actual solo acepta:

- `status`
- `updatedBy`

El backend toma `vendor_id` desde la orden ya guardada en base de datos.

Implicacion:

- si la orden no tiene `vendor_id`, la carga al camion falla
- la UI no puede resolver eso solo desde frontend

Para soportar la UX propuesta hay que hacer una de estas dos cosas:

1. extender backend para aceptar `vendorId` en la transicion a `CARGADO_CAMION`
2. o limitar la UI a cargar solo pedidos que ya vengan asignados a un rutero/vendedor

### 3.2 Calculo de bultos y unidades dentro del picking modal

Gemini asume que `GET /orders/:id` ya trae lo necesario para calcular:

- bultos
- unidades sueltas
- `unitsPerBulk`

Hoy no es cierto.

El detalle real de `GET /orders/:id` incluye por item:

- `productId`
- `productName`
- `barcode`
- `quantity`
- `unitPrice`
- `subtotal`

No incluye:

- `unitsPerBulk`
- `stockBulks`
- `stockUnits`
- `presentation`

Implicacion:

- el calculo de picking no puede hacerse de forma robusta solo con el payload actual

La forma correcta es extender backend para que `GET /orders/:id` devuelva al menos:

- `presentation`
- `unitsPerBulk`

Opcionalmente tambien:

- `requestedBulks`
- `requestedUnits`

## 4. Recomendacion correcta antes de implementarlo

Antes de crear `warehouse-dashboard-page.tsx`, conviene cerrar este orden:

1. backend:
   - ampliar `GET /orders/:id` con `unitsPerBulk` y `presentation`
2. decision funcional:
   - definir si `vendor_id` se asigna antes o durante `CARGADO_CAMION`
3. solo despues:
   - crear la pagina React
   - agregar ruta en `web/src/App.tsx`
   - agregar acceso en `app-layout`

## 5. Si se quisiera implementarlo ya mismo sin tocar backend

La version viable hoy seria mas limitada:

- columna `RECIBIDO`
- columna `EN_PREPARACION`
- columna `ALISTADO`
- columna `CARGADO_CAMION`
- acciones de cambio de estado
- detalle simple del pedido sin calculo confiable de bultos
- sin selector de vendedor en la ultima transicion

Eso funcionaria, pero no cumpliria todo lo que Gemini propone.

## 6. Conclusion

Gemini detecto bien la brecha de negocio.

Lo que no detecto bien fue el contrato real del backend.

La idea es util como direccion funcional, pero antes de implementarla conviene ajustar backend en dos puntos:

- `vendorId` en carga al camion
- `unitsPerBulk` en detalle de pedido

Hasta que eso no cambie, el prompt debe tomarse como diseno aspiracional, no como implementacion directa.
