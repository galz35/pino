# GitHub Verificacion y Descarga

Fecha de corte: 2026-04-03

## 1. Objetivo

Este documento existe para que una IA local como Gemini no se confunda con estados viejos, commits parciales o carpetas históricas.

Debe usarse para responder tres preguntas:

1. cuál es el repo correcto
2. cuál es el commit de referencia del corte bueno
3. cómo validar que GitHub y el VPS tienen exactamente lo mismo

## 2. Repo correcto

Repositorio correcto:

- `galz35/pino`

Ruta viva en este VPS:

- `/opt/apps/pino`

Rama correcta:

- `main`

No asumir:

- ramas temporales
- carpetas de pruebas locales fuera del repo
- snapshots en `/tmp`
- documentación histórica sin contrastarla con `main`

## 3. Commit de referencia de este corte

Commit actual esperado:

- `8342c9e`
- mensaje: `feat: improve mobile sync visibility and docs`

Si Gemini descarga el repo y no ve ese commit o uno más nuevo encima de ese mismo historial, entonces no está leyendo el corte correcto.

## 4. Qué debe considerar como fuente de verdad

Fuentes de verdad del código:

- `backend/src`
- `web/src`
- `flutter/lib`

Fuentes de verdad de documentación consolidada:

- `docs/00_INDEX.md`
- `docs/01_GEMINI_HANDOFF.md`
- `docs/02_MAPA_DEL_PROYECTO.md`
- `docs/03_ESTRUCTURA_DEL_SISTEMA.md`
- `docs/04_FLUJOS_DE_TRABAJO.md`
- `docs/05_MANUAL_DE_USUARIO.md`
- `docs/06_BASE_DE_DATOS_ESTADO_ACTUAL.md`
- `docs/12_CUMPLIMIENTO_REQUERIMIENTO_2026-04-02.md`

Fuentes históricas útiles pero no prioritarias:

- `plan/2026-04-01/`
- `flutter/docs/`

## 5. Qué no debe interpretar mal

Gemini no debe concluir esto sin verificar:

- que React está al `20%`
- que faltan módulos completos si esos módulos sí existen en `web/src/pages`
- que Flutter es solo maqueta si ya existe `flutter/lib/features`
- que un documento viejo del plan refleja el estado actual si no coincide con `main`

Regla:

- primero leer código vivo
- luego contrastar con `docs/`
- después usar `plan/` solo como contexto histórico

## 6. Cómo descargar bien el repo

Opción simple:

```bash
git clone ssh://git@ssh.github.com:443/galz35/pino.git
cd pino
git checkout main
git pull --ff-only origin main
```

Si Gemini solo inspecciona el repo ya clonado, debe validar:

```bash
git status --short --branch
git log --oneline --decorate -5
git rev-parse HEAD
git fetch origin
git rev-parse origin/main
```

Resultado esperado del corte bueno:

- `git status`: limpio
- `HEAD == origin/main`
- commit visible: `8342c9e`

## 7. Cómo contrastar GitHub contra este VPS

En este VPS la copia viva está en:

- `/opt/apps/pino`

Chequeo mínimo:

```bash
git -C /opt/apps/pino fetch origin
git -C /opt/apps/pino status --short --branch
git -C /opt/apps/pino rev-parse HEAD
git -C /opt/apps/pino rev-parse origin/main
git -C /opt/apps/pino log --oneline --decorate -5
```

La verificación correcta es:

1. `status` limpio
2. `HEAD` igual a `origin/main`
3. el commit `8342c9e` presente en la punta o debajo de un commit posterior coherente

## 8. Qué debe revisar Gemini primero

Orden recomendado:

1. `README.md`
2. `docs/00_INDEX.md`
3. `docs/01_GEMINI_HANDOFF.md`
4. `docs/12_CUMPLIMIENTO_REQUERIMIENTO_2026-04-02.md`
5. `web/src/App.tsx`
6. `backend/src/app.module.ts`
7. `flutter/lib/main.dart`
8. `flutter/lib/features/`

## 9. Qué módulos sí existen hoy

Backend real:

- auth
- users
- stores
- products
- sales
- inventory
- orders
- suppliers
- accounts-receivable
- collections
- accounts-payable
- returns
- routes
- sync
- websocket/events

React real:

- dashboard
- billing
- cash register
- products
- inventory
- suppliers
- receivables
- pending orders
- dispatcher
- warehouse
- control tower
- delivery route
- reports
- vendors
- quick sale
- collections
- master admin

Flutter real:

- auth
- home
- catalog
- clients
- orders
- deliveries
- collections
- returns
- warehouse
- startup

## 10. Prompt corto recomendado para Gemini

Usa algo así:

```text
Trabaja sobre el repo galz35/pino en la rama main. Antes de concluir estado o porcentaje, valida que el commit local coincida con origin/main y usa como fuente de verdad backend/src, web/src, flutter/lib y docs/00_INDEX.md. No uses plan/ como fuente principal si contradice el código vivo. Contrasta rutas en web/src/App.tsx, módulos backend en backend/src/app.module.ts y features móviles en flutter/lib/features antes de afirmar faltantes.
```

## 11. Veredicto corto

Si Gemini quiere “buscar bien GitHub”, la regla es simple:

- repo correcto: `galz35/pino`
- rama correcta: `main`
- commit de referencia del corte: `8342c9e`
- fuente de verdad: código vivo + docs consolidados
