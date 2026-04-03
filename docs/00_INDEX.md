# Documentacion Principal

Fecha de corte: 2026-04-02

Estado del proyecto en este corte:

- Backend: 100% del alcance actual
- React web: 100% del alcance actual
- Flutter: 100% del alcance móvil actual

Este directorio esta pensado como punto de entrada rapido para humanos o para una IA local como Gemini.

Orden recomendado de lectura:

1. [README.md](../README.md)
2. [01_GEMINI_HANDOFF.md](./01_GEMINI_HANDOFF.md)
3. [02_MAPA_DEL_PROYECTO.md](./02_MAPA_DEL_PROYECTO.md)
4. [03_ESTRUCTURA_DEL_SISTEMA.md](./03_ESTRUCTURA_DEL_SISTEMA.md)
5. [04_FLUJOS_DE_TRABAJO.md](./04_FLUJOS_DE_TRABAJO.md)
6. [05_MANUAL_DE_USUARIO.md](./05_MANUAL_DE_USUARIO.md)
7. [06_BASE_DE_DATOS_ESTADO_ACTUAL.md](./06_BASE_DE_DATOS_ESTADO_ACTUAL.md)
8. [07_FLUTTER_ESTRATEGIA_Y_PAUSA.md](./07_FLUTTER_ESTRATEGIA_Y_PAUSA.md)
9. [08_VALIDACION_GEMINI_WAREHOUSE.md](./08_VALIDACION_GEMINI_WAREHOUSE.md)
10. [09_WAREHOUSE_WEB_PENDIENTE.md](./09_WAREHOUSE_WEB_PENDIENTE.md)
11. [10_FLUTTER_PRINCIPIOS_UX_CAMPO.md](./10_FLUTTER_PRINCIPIOS_UX_CAMPO.md)
12. [11_AUDITORIA_DISENO_REACT_2026-04-02.md](./11_AUDITORIA_DISENO_REACT_2026-04-02.md)
13. [12_CUMPLIMIENTO_REQUERIMIENTO_2026-04-02.md](./12_CUMPLIMIENTO_REQUERIMIENTO_2026-04-02.md)
14. [13_GITHUB_VERIFICACION_Y_DESCARGA.md](./13_GITHUB_VERIFICACION_Y_DESCARGA.md)

Script operativo manual de este VPS:

- `./manual_update_dev.sh`
  - `all`: pull + backend + web + pm2 save
  - `backend`: pull + backend
  - `web`: pull + web
  - `local-all`: sin pull, recompila y republica con el estado local

Documentos historicos que siguen siendo utiles:

- [plan/2026-04-01/12-checklist-avance.md](../plan/2026-04-01/12-checklist-avance.md)
- [plan/2026-04-01/14-barrido-estructura-react.md](../plan/2026-04-01/14-barrido-estructura-react.md)
- [plan/2026-04-01/15-mapa-consumo-api-react.md](../plan/2026-04-01/15-mapa-consumo-api-react.md)
- [plan/2026-04-01/17-barrido-backend-vs-requerimiento.md](../plan/2026-04-01/17-barrido-backend-vs-requerimiento.md)
- [plan/2026-04-01/03-analisis-gap-flutter.md](../plan/2026-04-01/03-analisis-gap-flutter.md)
- [plan/2026-04-01/07-plan-flutter-movil.md](../plan/2026-04-01/07-plan-flutter-movil.md)
- [plan/2026-04-01/19-flutter-corte-inicial-2026-04-02.md](../plan/2026-04-01/19-flutter-corte-inicial-2026-04-02.md)
- [flutter/docs/00_INDEX.md](../flutter/docs/00_INDEX.md)
- [flutter/docs/02_MAPA_MODULOS_Y_FLUJOS.md](../flutter/docs/02_MAPA_MODULOS_Y_FLUJOS.md)
- [flutter/docs/03_MAPA_API_MOVIL.md](../flutter/docs/03_MAPA_API_MOVIL.md)

Fuentes de verdad del sistema:

- codigo backend: `backend/src`
- codigo web: `web/src`
- codigo flutter actual: `flutter/` (app móvil operativa del alcance actual)
- DDL base: `backend/src/database/schema.sql`
- estado vivo de la BD: PostgreSQL `multitienda_db` en el contenedor `postgres_alacaja`
