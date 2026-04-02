# 19 - Flutter Corte Inicial 2026-04-02

## 1. Objetivo del corte

Salir de cero y dejar una base móvil real conectada al backend actual de `pino`.

## 2. Lo que quedó implementado

- bootstrap Flutter real en `flutter/lib/main.dart`
- `ProviderScope` y app shell
- router con `go_router`
- runtime config para:
  - API base
  - socket base
  - socket path
  - namespace
- cliente HTTP con `dio`
- almacenamiento seguro con `flutter_secure_storage`
- repositorio de autenticación
- controlador de sesión con Riverpod
- `SplashScreen`
- `LoginScreen`
- `HomeScreen`
- lectura de tiendas asignadas del usuario
- normalización de rol para UI móvil

## 3. Validación técnica

Validado en este corte:

- `flutter analyze` -> OK
- `flutter test` -> OK

## 4. Hallazgo importante del repo

Se corrigió un problema de versionado:

- `flutter` estaba como gitlink `160000`
- no existía `.gitmodules`
- el repo padre no podía absorber archivos móviles

Se convirtió `flutter/` en carpeta normal del repo principal para poder versionar la app móvil dentro de `pino`.

## 5. Lo que falta ahora

- `drift`
- cola offline
- realtime por `socket_io_client`
- catálogo móvil
- preventa
- ruta
- cobros
- devoluciones

## 6. Estado honesto

Flutter ya no está en cero.

Tampoco está listo para producción móvil todavía.

Este corte deja una base sólida para seguir trabajando sin volver a empezar desde el template.
