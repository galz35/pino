const axios = require('axios');

const API_URL = 'http://localhost:3010/api';

/**
 * Escenario de la Vida Real: 
 * - 1 Distribuidora (Almacén Central)
 * - 2 Tiendas de Venta al Público
 * - Usuarios: Master Admin (Dueño), Encargado de Distribuidora, Cajeros.
 * - Flujo: Entrada a Distribuidora -> Salida a Tienda -> Venta a Público.
 */

async function runRealLifeTest() {
  console.log('🏗️ --- INICIANDO ESCENARIO DE VIDA REAL: DISTRIBUIDORA + 2 TIENDAS ---\n');

  try {
    // ---------------------------------------------------------
    // 1. SETUP DE SEGURIDAD Y ESTRUCTURA
    // ---------------------------------------------------------
    console.log('1. Registrando Master Admin...');
    const authRecord = await axios.post(`${API_URL}/auth/register`, {
      email: `master_${Date.now()}@multitienda.com`,
      password: 'masterpassword',
      name: 'Don Pino (Dueño)',
      role: 'master-admin'
    });
    const token = authRecord.data.accessToken;
    const masterId = authRecord.data.user.id;
    const headers = { Authorization: `Bearer ${token}` };
    console.log('✅ Estructura base lista.\n');

    // 2. Crear Cadena
    const chainRes = await axios.post(`${API_URL}/chains`, { name: 'Comercial Los Pinos' }, { headers });
    const chainId = chainRes.data.id;

    // 3. Crear 3 Locales (1 Distribuidora y 2 Tiendas)
    console.log('2. Configurando Nodos Logísticos...');
    const nodes = [];
    const names = ['Distribuidora Central', 'Tienda Norte', 'Tienda Sur'];
    for (const name of names) {
      const res = await axios.post(`${API_URL}/stores`, { chainId, name }, { headers });
      nodes.push({ id: res.data.id, name: res.data.name });
    }
    const [distribuidora, tiendaNorte, tiendaSur] = nodes;
    console.log(`✅ ${distribuidora.name}, ${tiendaNorte.name} y ${tiendaSur.name} creadas.\n`);

    // 4. Crear Producto Maestro (Ej: Arroz 50lb)
    console.log('3. Creando Producto Maestro...');
    const prodRes = await axios.post(`${API_URL}/products`, {
      storeId: distribuidora.id,
      description: 'Arroz Super Extra 50lb',
      barcode: 'ARROZ-50',
      salePrice: 1200,
      costPrice: 950
    }, { headers });
    const productId = prodRes.data.id;
    console.log(`✅ Producto registrado en catálogo.\n`);

    // ---------------------------------------------------------
    // 2. LOGÍSTICA DE INVENTARIO (DISTRIBUIDORA)
    // ---------------------------------------------------------
    console.log('4. RECIBIENDO CARGA EN DISTRIBUIDORA (1000 unidades)...');
    await axios.post(`${API_URL}/inventory/adjust`, {
      storeId: distribuidora.id,
      productId: productId,
      userId: masterId,
      type: 'IN',
      quantity: 1000,
      reference: 'Compra a Proveedor Maíz S.A.'
    }, { headers });

    // 5. Traslado a Tienda Norte (Simulado como OUT de Dist y IN en Tienda)
    console.log('5. TRASLADANDO STOCK A TIENDA NORTE (200 unidades)...');
    // Salida de Distribuidora
    await axios.post(`${API_URL}/inventory/adjust`, {
      storeId: distribuidora.id,
      productId: productId,
      userId: masterId,
      type: 'OUT',
      quantity: 200,
      reference: 'Traslado a Tienda Norte'
    }, { headers });

    // Entrada en Tienda Norte (Primero creamos el producto en esa tienda)
    const prodNorte = await axios.post(`${API_URL}/products`, {
      storeId: tiendaNorte.id,
      description: 'Arroz Super Extra 50lb',
      barcode: 'ARROZ-50',
      salePrice: 1250, // Precio más alto en tienda
      costPrice: 950
    }, { headers });

    await axios.post(`${API_URL}/inventory/adjust`, {
      storeId: tiendaNorte.id,
      productId: prodNorte.data.id,
      userId: masterId,
      type: 'IN',
      quantity: 200,
      reference: 'Recepción desde Distribuidora'
    }, { headers });
    console.log('✅ Traslado completado.\n');

    // ---------------------------------------------------------
    // 3. OPERACIÓN DE VENTA (TIENDA NORTE)
    // ---------------------------------------------------------
    console.log('6. ABRIENDO CAJA EN TIENDA NORTE...');
    const shiftRes = await axios.post(`${API_URL}/cash-shifts`, {
      storeId: tiendaNorte.id,
      userId: masterId,
      startingCash: 1000
    }, { headers });
    const shiftId = shiftRes.data.id;

    console.log('7. EJECUTANDO VENTA DE ALTO VOLUMEN...');
    // Simulamos venta de 10 sacos
    const saleRes = await axios.post(`${API_URL}/sales/process`, {
      storeId: tiendaNorte.id,
      cashShiftId: shiftId,
      cashierId: masterId,
      ticketNumber: 'T-0001',
      paymentMethod: 'CASH',
      items: [{ productId: prodNorte.data.id, quantity: 10, unitPrice: 1250 }]
    }, { headers });
    console.log(`✅ Venta Exitosa. ID: ${saleRes.data.saleId}\n`);

    // ---------------------------------------------------------
    // 4. VALIDACIÓN DE CONSISTENCIA
    // ---------------------------------------------------------
    console.log('8. AUDITANDO KÁRDEX FINAL...');
    const kDist = await axios.get(`${API_URL}/inventory/kardex?storeId=${distribuidora.id}&productId=${productId}`, { headers });
    const kNorte = await axios.get(`${API_URL}/inventory/kardex?storeId=${tiendaNorte.id}&productId=${prodNorte.data.id}`, { headers });

    console.log(`📊 Reporte de Stock:`);
    console.log(` - Distribuidora: ${kDist.data[0].balance} sacos (Esperado: 800)`);
    console.log(` - Tienda Norte: ${kNorte.data[0].balance} sacos (Esperado: 190)`);
    
    // Verificando Caja
    const shiftFinal = await axios.get(`${API_URL}/cash-shifts/active?storeId=${tiendaNorte.id}`, { headers });
    console.log(` - Efectivo en Caja Norte: $${shiftFinal.data.actual_cash} (Esperado: $13500)\n`);

    if (kDist.data[0].balance == 800 && kNorte.data[0].balance == 190) {
      console.log('🏁 --- ESCENARIO COMPLETADO CON ÉXITO: SISTEMA ROBUSTO --- 🏁');
    } else {
      console.log('⚠️ Advertencia: Algunos balances no coinciden con el flujo esperado.');
    }

  } catch (error) {
    console.error('❌ ERROR FATAL EN EL ESCENARIO:');
    if (error.response) {
      console.error(JSON.stringify(error.response.data, null, 2));
    } else {
      console.error(error.message);
    }
  }
}

runRealLifeTest();
