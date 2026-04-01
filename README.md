# Sistema MultiTienda (v2.0)

Este repositorio contiene la migración completa del Sistema MultiTienda y Los Pinos Mobile, pasando de una arquitectura Serverless (Firebase/Next.js) a una infraestructura relacional robusta (PostgreSQL/NestJS/React Vite).

## Estructura del Proyecto

El proyecto sigue una estructura de monorepo lógico dividido en 3 pilares principales:

- `/backend`: API REST, Lógica de Negocio y WebSockets (NestJS + TypeORM + PostgreSQL).
- `/web`: Aplicación de Punto de Venta PWA SPA (Vite + React + Tailwind + Radix UI).
- `/flutter`: [Futuro] Aplicación móvil conectada a esta API (Clean Architecture).

## Decisiones Técnicas

- **Base de datos:** PostgreSQL para asegurar integridad referencial y cumplir requisitos financieros de Kárdex y Caja.
- **Frontend SPA:** Cambio de Next.js (SSR) a React + Vite (SPA) para maximizar la velocidad y aprovechar `IndexedDB` en transacciones POS offline rápidas.
- **Sincronización:** Uso de un patrón Last-Write-Wins junto con el API Batch de NestJS para solventar transacciones locales generadas por fallos de red.
- **Micro UI Components:** Reutilización del 100% de la capa gráfica original mediante `@radix-ui` y `Tailwind CSS`.
