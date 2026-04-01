# 03 - Analisis de Brechas: Flutter Movil

Fecha de corte: 2026-04-01

## 1. Correccion importante

Este documento reemplaza una version anterior que describia Flutter como si ya tuviera modulos funcionales.

Eso ya no es la fuente de verdad.

Estado real hoy:

- existe scaffold base en `flutter/`
- el SDK ya esta instalado localmente
- `pubspec.yaml` ya incluye el stack tecnico recomendado
- no existe implementacion real de negocio todavia

Por tanto, cualquier referencia a pantallas Flutter ya hechas debe considerarse obsoleta.

## 2. Estado real actual

### 2.1 Lo que si existe

- carpeta `flutter/`
- `pubspec.yaml`
- `pubspec.lock`
- `lib/main.dart` de template
- `README.md` de Flutter
- dependencias base ya agregadas

### 2.2 Lo que no existe todavia

- auth real
- router real
- session manager
- api client conectado
- repositorios
- modelos de dominio
- base local `drift`
- cola offline
- listener realtime
- pantallas por rol

## 3. Stack recomendado ya decidido

El stack seleccionado para cuando se retome es:

- `flutter_riverpod`
- `go_router`
- `dio`
- `flutter_secure_storage`
- `connectivity_plus`
- `socket_io_client`
- `drift`
- `sqlite3_flutter_libs`
- `path_provider`
- `path`

Dev tools:

- `build_runner`
- `drift_dev`

## 4. Brechas reales hoy

### 4.1 Capa de arranque

Falta:

- bootstrap real de aplicacion
- configuracion por entorno
- tema y shell visual

### 4.2 Capa de sesion

Falta:

- login
- persistencia segura de tokens
- refresh token
- logout limpio
- guards por rol

### 4.3 Capa de networking

Falta:

- cliente `dio`
- interceptores
- manejo centralizado de errores
- mapeo de contratos backend

### 4.4 Capa local/offline

Falta:

- esquema `drift`
- cache local
- cola de sync
- reconciliacion de operaciones pendientes

### 4.5 Realtime

Falta:

- conexion Socket.IO
- listeners de eventos
- invalidacion o merge local de datos

### 4.6 Features de negocio

Falta todo el frente movil de negocio:

- vendedor/preventa
- rutero
- cartera/cobros
- devoluciones
- dashboard movil
- bodega movil opcional

## 5. Contrato objetivo con el backend actual

La futura app movil debe colgarse del backend ya funcional:

- API base publica: `https://www.rhclaroni.com/api-dev`
- socket host: `https://www.rhclaroni.com`
- socket path: `/api-dev/socket.io`
- namespace: `/events`

No se debe amarrar a `localhost`.

## 6. Riesgos tecnicos si se retoma mal

Los errores mas probables si se arranca sin orden son:

- meter demasiada generacion de codigo desde el inicio
- construir pantallas antes de cerrar auth/session/api
- duplicar logica de negocio que ya existe en React/Nest
- usar contratos distintos a los del backend real
- intentar offline-first completo antes de tener online-first estable

## 7. Recomendacion de reanudacion

Cuando Flutter se retome, el orden correcto es:

1. bootstrap
2. config
3. auth
4. router
5. api client
6. secure storage
7. drift
8. sync
9. realtime
10. features de negocio

## 8. Documento relacionado

La referencia consolidada para este frente esta en:

- `docs/07_FLUTTER_ESTRATEGIA_Y_PAUSA.md`
