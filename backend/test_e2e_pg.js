const axios = require('axios');

const API_URL = 'http://localhost:3010/api';
let token = '';
let userId = '';
let chainId = '';
let storeId = '';
let productId = '';
let shiftId = '';

async function runTests() {
  console.log('🚀 Iniciando Tests Rigurosos del Backend MultiTienda...\n');

  try {
    // 1. Registro de Admin Maestro
    console.log('1. Registrando Master Admin...');
    const registerAdmin = await axios.post(`${API_URL}/auth/register`, {
      email: `admin_${Date.now()}@multitienda.com`,
      password: 'password123',
      name: 'Admin Maestro de Pruebas',
      role: 'master-admin'
    });
    token = registerAdmin.data.accessToken;
    userId = registerAdmin.data.user.id;
    console.log('✅ Admin registrado y logueado.\n');

    const headers = { Authorization: `Bearer ${token}` };

    // 2. Crear una Cadena
    console.log('2. Creando Cadena de Tiendas...');
    const chainRes = await axios.post(`${API_URL}/chains`, {
      name: 'Cadena de Prueba Los Pinos',
      ownerName: 'Gustavo Lira',
      ownerEmail: 'gustavo@lospinos.com'
    }, { headers });
    chainId = chainRes.data.id;
    console.log(`✅ Cadena creada: ${chainId}\n`);

    // 3. Crear una Tienda
    console.log('3. Creando Tienda...');
    const storeRes = await axios.post(`${API_URL}/stores`, {
      chainId: chainId,
      name: 'Sucursal Central Test',
      address: 'Managua, Nicaragua',
      phone: '8888-8888'
    }, { headers });
    storeId = storeRes.data.id;
    console.log(`✅ Tienda creada: ${storeId}\n`);

    // 4. Crear un Departamento
    console.log('4. Creando Departamento...');
    const deptRes = await axios.post(`${API_URL}/departments`, {
      storeId: storeId,
      name: 'Lácteos',
      description: 'Productos derivados de la leche'
    }, { headers });
    const deptId = deptRes.data.id;
    console.log(`✅ Departamento creado: ${deptId}\n`);

    // 5. Crear un Producto
    console.log('5. Creando Producto...');
    const prodRes = await axios.post(`${API_URL}/products`, {
      storeId: storeId,
      departmentId: deptId,
      barcode: '74110001',
      description: 'Leche Liter 1lt',
      salePrice: 45.50,
      costPrice: 38.00
    }, { headers });
    productId = prodRes.data.id;
    console.log(`✅ Producto creado: ${productId}\n`);

    // 5.1 Ajustar Stock inicial (Puro PG)
    console.log('5.1 Ajustando Stock inicial...');
    await axios.post(`${API_URL}/inventory/adjust`, {
      storeId: storeId,
      productId: productId,
      userId: userId,
      type: 'IN',
      quantity: 100,
      reference: 'Seed de prueba'
    }, { headers });
    console.log('✅ Stock ajustado (100 unidades).\n');

    // 6. Abrir Caja
    console.log('6. Abriendo Turno de Caja...');
    const shiftRes = await axios.post(`${API_URL}/cash-shifts`, {
      storeId: storeId,
      userId: userId,
      startingCash: 500.00
    }, { headers });
    shiftId = shiftRes.data.id;
    console.log(`✅ Caja abierta: ${shiftId}\n`);

    // 7. Procesar una Venta (Transacción SQL Pura)
    console.log('7. Procesando Venta Transaccional...');
    const saleRes = await axios.post(`${API_URL}/sales/process`, {
      storeId: storeId,
      cashShiftId: shiftId,
      cashierId: userId,
      ticketNumber: `TKT-${Date.now()}`,
      paymentMethod: 'CASH',
      items: [
        { productId: productId, quantity: 2, unitPrice: 45.50 }
      ]
    }, { headers });
    console.log('✅ Venta procesada correctamente.');
    console.log(`Mensaje: ${saleRes.data.message}\n`);

    // 8. Verificar Kárdex
    console.log('8. Verificando Movimientos de Kárdex...');
    const kardexRes = await axios.get(`${API_URL}/inventory/kardex?storeId=${storeId}&productId=${productId}`, { headers });
    console.log(`✅ Movimientos encontrados: ${kardexRes.data.length}`);
    console.log(`Último saldo: ${kardexRes.data[0].balance} unidades.\n`);

    console.log('🏁 --- TODOS LOS TESTS PASARON EXITOSAMENTE --- 🏁');

  } catch (error) {
    console.error('❌ ERROR EN LOS TESTS:');
    if (error.response) {
      console.error(JSON.stringify(error.response.data, null, 2));
    } else {
      console.error(error.message);
    }
    process.exit(1);
  }
}

runTests();
