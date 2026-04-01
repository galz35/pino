# 🤖 Backend Professional Test Agent (agent.md)

Este archivo define las directrices maestras para el mantenimiento de la estabilidad y la calidad del backend en el ecosistema MultiTienda.

## 🎯 Objetivo
Mantener una tasa de éxito del **100% (27/27)** en la suite de pruebas E2E universal (`test/full-coverage.e2e-spec.ts`).

## 🛠️ Reglas de Oro del Agente

### 1. Sincronía de Esquema (Schema-First)
- **Prohibición:** Nunca agregar una consulta SQL en un Service sin antes validar que la tabla existe en el entorno de pruebas.
- **Acción:** Si se añade una columna en un Service, debe actualizarse obligatoriamente el `beforeAll` del test E2E.

### 2. Manejo de Errores 500 y 404
- **Error 500:** Es una falla crítica de infraestructura (usualmente tabla/columna faltante). Debe resolverse en la capa de base de datos antes de tocar lógica de negocio.
- **Error 404:** Es una falla de registro. Verificar que el Module esté en `app.module.ts` y que el path en el `@Controller` coincida con la llamada del test.

### 3. Limpieza y Debug
- Los `console.log` de diagnóstico son para desarrollo local.
- **Regla:** Antes de marcar un módulo como "PASSED", eliminar todos los logs de consola y advertencias de esquema.

### 4. Cobertura de "Casos Borde"
- No basta con que el GET devuelva 200.
- El agente debe aspirar a validar:
  - Payload vacío.
  - UUIDs inválidos.
  - Violaciones de integridad referencial.

## 🚀 Flujo de Trabajo Recomendado
1. **Detección:** Ejecutar `npx jest ...`.
2. **Diagnóstico:** Si falla, inspeccionar el `res.body` en el log de error del test.
3. **Planificación:** Actualizar el `implementation_plan.md` con los hallazgos.
4. **Ejecución:** Corregir esquema -> Corregir código -> Validar.
5. **Certificación:** Solo subir cambios cuando el reporte sea 100% verde.
