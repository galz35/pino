"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const app_module_1 = require("./src/app.module");
const database_service_1 = require("./src/database/database.service");
const request = require("supertest");
async function runTests() {
    var _a;
    console.log('🔄 Iniciando NestJS E2E Test Suite...');
    const app = await core_1.NestFactory.create(app_module_1.AppModule, { logger: false });
    await app.init();
    const db = app.get(database_service_1.DatabaseService);
    const results = [];
    const startTimer = () => performance.now();
    const endTimer = (start) => Math.round(performance.now() - start);
    // === 1. Setup Test Data ===
    console.log('📦 Generando datos de prueba temporales...');
    const rnd = Math.floor(Math.random() * 10000);
    const storeRes = await db.query(`INSERT INTO stores (name, code, type) VALUES ('Store_${rnd}', 'S${rnd}', 'MAIN') RETURNING id`);
    const storeId = storeRes.rows[0].id;
    const adminEmail = `admin_${rnd}@test.com`;
    const adminRes = await db.query(`INSERT INTO users (email, password_hash, name, role) VALUES ($1, '$2b$10$wT0XkLwMjYyT7Xb.A.1jWe2Xm.9EOWm.uM2XjD0eXjD0eXjD0eXjD', 'Admin_${rnd}', 'master-admin') RETURNING id`, [adminEmail]);
    const adminId = adminRes.rows[0].id;
    const vendorRes = await db.query(`INSERT INTO users (email, password_hash, name, role) VALUES ($1, 'hash', 'Vendor_${rnd}', 'vendor') RETURNING id`, [`vendor_${rnd}@test.com`]);
    const vendorId = vendorRes.rows[0].id;
    const prodRes = await db.query(`INSERT INTO products (store_id, description, barcode, current_stock, uses_inventory, sale_price) VALUES ($1, 'Prod_${rnd}', 'B${rnd}', 100, true, 25) RETURNING id`, [storeId]);
    const productId = prodRes.rows[0].id;
    const clientRes = await db.query(`INSERT INTO clients (store_id, name) VALUES ($1, 'Client_${rnd}') RETURNING id`, [storeId]);
    const clientId = clientRes.rows[0].id;
    // === 2. Authenticate ===
    let token = '';
    try {
        const regRes = await request(app.getHttpServer()).post('/auth/register').send({ email: `real_${rnd}@test.com`, password: 'password', name: 'Real', role: 'master-admin' });
        const loginRes = await request(app.getHttpServer()).post('/auth/login').send({ email: regRes.body.user.email, password: 'password' });
        token = loginRes.body.access_token;
    }
    catch (e) {
        console.error('No se pudo autenticar:', e);
    }
    // === 3. Tester Helper ===
    let shiftId, saleId, zoneId, accountId, deliveryId, routeId, pendingOrderId;
    async function testApi(method, endpoint, body) {
        const start = startTimer();
        let res;
        const req = request(app.getHttpServer())[method](endpoint).set('Authorization', `Bearer ${token}`);
        if (body)
            res = await req.send(body);
        else
            res = await req;
        const duration = endTimer(start);
        results.push({
            modulo: endpoint.split('/')[1] || 'root',
            endpoint: `${method.toUpperCase()} ${endpoint}`,
            envio: body ? JSON.stringify(body).substring(0, 100) : 'Ninguno',
            status: res.status,
            retorno: JSON.stringify(res.body).substring(0, 150) + (JSON.stringify(res.body).length > 150 ? '...' : ''),
            tiempoFormat: duration <= 20 ? '⚡ ' + duration + 'ms' : '🐢 ' + duration + 'ms',
            tiempoMs: duration
        });
        return res.body;
    }
    console.log('🚀 Ejecutando peticiones a todos los endpoints...');
    // Phase A Fixes
    await testApi('get', '/auth/profile');
    await testApi('get', `/users?storeId=${storeId}&role=vendor`);
    await testApi('post', '/users', { email: `staff_${rnd}@test.com`, password: 'pass', name: 'Staff', role: 'store-admin', storeId });
    await testApi('get', `/departments?storeId=${storeId}&type=sub`);
    const shiftRes = await testApi('post', '/cash-shifts/open', { storeId, userId: adminId, openingCash: 100 });
    shiftId = shiftRes.id || ((_a = shiftRes.shift) === null || _a === void 0 ? void 0 : _a.id);
    if (shiftId)
        await testApi('get', `/cash-shifts/${shiftId}`);
    else
        console.log('⚠️ Shift ID missing, skipping sales tests...');
    if (shiftId) {
        const saleRes = await testApi('post', '/sales/process', { storeId, shiftId, cashierId: adminId, paymentMethod: 'Efectivo', items: [{ productId, quantity: 2, salePrice: 25 }] });
        saleId = saleRes.saleId || saleRes.id;
        if (saleId) {
            await testApi('get', `/sales/${saleId}`);
            await testApi('post', `/sales/${saleId}/return`, { items: [{ productId, quantity: 1 }], reason: 'Defecto' });
        }
        await testApi('post', `/cash-shifts/${shiftId}/close`, { storeId, userId: adminId, expectedCash: 150, difference: 0 });
    }
    // Phase B Modules
    const zoneRes = await testApi('post', '/store-zones', { storeId, name: 'Zona Centro' });
    zoneId = zoneRes.id;
    await testApi('get', `/store-zones?storeId=${storeId}`);
    if (zoneId)
        await testApi('patch', `/store-zones/${zoneId}`, { name: 'Zona Sur' });
    await testApi('post', '/visit-logs', { storeId, vendorId, clientId, notes: 'Interesado en compras' });
    await testApi('get', `/visit-logs?storeId=${storeId}`);
    await testApi('post', '/vendor-inventories/transaction', { storeId, vendorId, productId, type: 'ASSIGN', quantity: 5, userId: adminId });
    await testApi('get', `/vendor-inventories/${vendorId}/${productId}`);
    await testApi('get', `/vendor-inventories/${vendorId}`);
    const accRes = await testApi('post', '/accounts-receivable', { storeId, clientId, totalAmount: 1000, description: 'Crédito' });
    accountId = accRes.id;
    await testApi('get', `/accounts-receivable?storeId=${storeId}&pending=true`);
    if (accountId) {
        await testApi('get', `/accounts-receivable/${accountId}`);
        await testApi('post', `/accounts-receivable/${accountId}/payments`, { amount: 200, paymentMethod: 'CASH' });
    }
    const delRes = await testApi('post', '/pending-deliveries', { storeId, orderId: saleId || storeId, address: 'Direccion Demo' });
    deliveryId = delRes.id;
    await testApi('get', `/pending-deliveries?storeId=${storeId}&unassigned=true`);
    if (deliveryId) {
        await testApi('patch', `/pending-deliveries/${deliveryId}`, { status: 'En Pre-ruta' });
        await testApi('post', '/pending-deliveries/assign-route', { deliveryIds: [deliveryId], ruteroId: vendorId });
    }
    const routeRes = await testApi('post', '/routes', { storeId, vendorId, clientIds: [clientId] });
    routeId = routeRes.id;
    await testApi('get', `/routes?storeId=${storeId}`);
    if (routeId)
        await testApi('patch', `/routes/${routeId}`, { status: 'in-progress' });
    const ordRes = await testApi('post', '/pending-orders', { storeId, clientName: 'Cliente Generico', items: [{ productId, quantity: 1 }], total: 50 });
    pendingOrderId = ordRes.id;
    await testApi('get', `/pending-orders?storeId=${storeId}`);
    if (pendingOrderId) {
        await testApi('post', '/pending-orders/dispatch', { orderIds: [pendingOrderId], dispatchedBy: 'Bodeguero' });
        await testApi('patch', `/pending-orders/${pendingOrderId}/status`, { status: 'Entregado' });
    }
    await testApi('post', '/errors', { message: 'Prueba E2E de error', location: 'Runner', storeId });
    await testApi('get', '/errors?limit=5');
    // === 4. Markdown Report Generator ===
    console.log('\n📊 Generando reporte...');
    // Sort by execution time descending (Slowest first)
    results.sort((a, b) => b.tiempoMs - a.tiempoMs);
    let md = '### Test de Rendimiento y Paridad Backend (NestJS)\n\n';
    md += `Prueba ejecutada probando **${results.length} endpoints**, simulando datos como peticiones y recepciones exactas de la DB vacía.\\n\\n`;
    md += '| Tiempo | Estado | Endpoint | Enviado (Truncado) | Recibido (Truncado) |\n';
    md += '|---|---|---|---|---|\n';
    for (const r of results) {
        const errorEmoji = r.status >= 400 ? '🔴' : '🟢';
        md += `| ${r.tiempoFormat} | ${errorEmoji} ${r.status} | \`${r.endpoint}\` | ${r.envio} | <details><summary>Respuesta</summary> ${r.retorno}</details> |\n`;
    }
    // Cleanup
    console.log('🧹 Limpiando test DB...');
    await db.query('DELETE FROM stores WHERE id = $1', [storeId]);
    await db.query(`DELETE FROM users WHERE email LIKE 'real_%@test.com'`);
    await app.close();
    // Output formatting requires storing to an artifact
    const fs = require('fs');
    fs.writeFileSync('./e2e-report.md', md);
    console.log('✅ Finalizado! Guardado en e2e-report.md');
}
runTests().catch(e => {
    console.error('Fatal Errror:', e);
    process.exit(1);
});
