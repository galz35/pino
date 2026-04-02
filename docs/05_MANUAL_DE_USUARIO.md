# Manual De Usuario

Este manual resume como se usa el sistema por rol. No incluye credenciales.

## 1. Master Admin

Pantallas principales:

- dashboard
- tiendas
- cadenas
- usuarios
- licencias
- monitor
- sync monitor
- configuracion
- zonas y sub-zonas

Tareas comunes:

1. crear cadena
2. crear tienda
3. crear usuarios globales o de tienda
4. revisar licencias
5. revisar errores
6. revisar sincronizacion

## 2. Store Admin

Pantallas principales:

- dashboard
- caja
- productos
- proveedores
- inventario
- usuarios
- reportes
- settings
- autorizaciones
- cuentas por cobrar

Tareas comunes:

1. administrar productos
2. administrar proveedores
3. revisar movimientos de inventario
4. abrir modulos de cobranza
5. revisar pedidos pendientes
6. administrar usuarios de tienda

## 3. Cashier

Pantallas principales:

- POS / billing
- cash register

Flujo tipico:

1. abrir turno de caja
2. buscar productos
3. asignar cliente si aplica
4. procesar venta
5. reimprimir ticket si hace falta
6. cerrar caja al final del turno

## 4. Inventory / Bodega

Pantallas principales:

- productos
- movimientos
- ajustes
- proveedores

Flujo tipico:

1. crear o editar producto
2. revisar stock
3. ejecutar ajuste
4. revisar kardex
5. registrar compras con factura proveedor

## 5. Dispatcher

Pantallas principales:

- pending orders
- dispatcher
- control tower

Flujo tipico:

1. revisar pedidos pendientes
2. preparar despacho
3. coordinar entregas
4. seguir estados operativos

## 6. Rutero

Pantallas principales:

- delivery route

Flujo tipico:

1. abrir su ruta asignada
2. revisar entregas pendientes
3. cambiar estado de la entrega
4. completar ruta

## 7. Vendedor Ambulante

Pantallas principales:

- quick sale
- clientes
- ventas

Flujo tipico:

1. revisar clientes
2. registrar o buscar cliente
3. vender rapido
4. registrar pedido
5. consultar ventas hechas

## 8. Sales Manager / Gestor de Ventas

Pantallas principales:

- dashboard de vendedores
- asignacion de ruta
- rutas
- clientes
- ventas
- zonas

Flujo tipico:

1. revisar zonas
2. asignar clientes o rutas
3. revisar visitas
4. registrar pedidos si aplica
5. coordinar operacion comercial de campo

## 9. Cobranza

Pantallas principales:

- `finance/receivables`
- `vendor-collections`

Flujo tipico:

1. ver cuentas pendientes
2. registrar abono o pago
3. revisar resumen diario

## 10. Compras y cuentas por pagar

Pantallas principales:

- proveedores
- factura proveedor

Flujo tipico:

1. crear o editar proveedor
2. registrar factura
3. definir contado o credito
4. si es credito, pagar parcial o total despues

## 11. Autorizaciones

Perfiles administrativos pueden:

1. ver autorizaciones pendientes
2. aprobar
3. rechazar

El sistema tambien puede mostrar alertas globales y campana de notificaciones.

## 12. App móvil Flutter

La app móvil está pensada para usuario de calle y bodega:

- acciones rápidas
- pocas pantallas
- botones grandes
- menos escritura manual

### Vendedor / Preventa móvil

Flujo típico:

1. iniciar sesión
2. elegir tienda
3. abrir preventa
4. seleccionar cliente
5. buscar producto
6. ajustar cantidades
7. guardar pedido
8. si no entra por red, revisar Home y confirmar que quedó en cola pendiente

### Rutero móvil

Flujo típico:

1. iniciar sesión
2. abrir ruta y entregas
3. revisar pedidos/paradas
4. cobrar si aplica
5. registrar devolución si aplica
6. si hay mala señal, volver a Home para revisar si el cobro o devolución quedó pendiente o fallido

### Bodega móvil

Flujo típico:

1. abrir tablero de bodega
2. ver pedido por estado
3. moverlo a preparación
4. alistarlo
5. cargarlo al camión con responsable

### Nota importante sobre señal

Hoy la app sí tiene base local y sesión persistida, pero todavía no se debe asumir que toda la operación funciona sin internet.

Existe:

- SQLite local
- cache de tiendas
- cache de catálogo
- cache de clientes
- cache de cartera
- cache de resumen de cobranza
- cache de rutas
- cache de entregas
- cola offline para pedido, cobro y devolución
- reintento automático básico cuando vuelve internet
- vista en Home de pendientes, fallidas y operaciones recientes

Todavía falta:

- sincronización completa de negocio
- reconciliación automática por mala señal
- operación continua 100% offline en todas las pantallas

### Qué debe hacer el usuario si ve mala señal

1. guardar la operación normalmente
2. volver a `Home`
3. revisar `Cola offline`
4. si aparece como `pendiente`, esperar recuperación de internet
5. si aparece como `fallida`, usar `Reintentar fallidas`

### Qué hace la app cuando vuelve internet

1. intenta reprocesar la cola local
2. refresca datos críticos de la tienda activa
3. actualiza catálogo, ruta o bodega si entra un evento realtime aplicable
