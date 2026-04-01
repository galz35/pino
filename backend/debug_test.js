const axios = require('axios');

const API_URL = 'http://localhost:3010/api';

async function runSingleTest() {
  try {
    console.log('1. Registrando...');
    const reg = await axios.post(`${API_URL}/auth/register`, {
      email: `t${Date.now()}@test.com`,
      password: 'password123',
      name: 'Tester',
      role: 'master-admin'
    });
    const token = reg.data.accessToken;
    const userId = reg.data.user.id;
    const headers = { Authorization: `Bearer ${token}` };

    console.log('2. Creando Cadena...');
    const chain = await axios.post(`${API_URL}/chains`, { name: 'C1' }, { headers });
    const chainId = chain.data.id;

    console.log('3. Creando Tienda...');
    const store = await axios.post(`${API_URL}/stores`, { chainId, name: 'S1' }, { headers });
    const storeId = store.data.id;

    console.log('4. Creando Dept...');
    const dept = await axios.post(`${API_URL}/departments`, { storeId, name: 'D1' }, { headers });
    const deptId = dept.data.id;

    console.log('5. Creando Prod...');
    const prod = await axios.post(`${API_URL}/products`, { 
      storeId, 
      departmentId: deptId, 
      description: 'P1', 
      salePrice: 10, 
      costPrice: 5,
      barcode: '123'
    }, { headers });
    const productId = prod.data.id;

    console.log('6. Ajustando Stock (IN)...');
    await axios.post(`${API_URL}/inventory/adjust`, {
      storeId,
      productId,
      userId,
      type: 'IN',
      quantity: 100,
      reference: 'Initial'
    }, { headers });

    console.log('7. Abriendo Caja...');
    const shift = await axios.post(`${API_URL}/cash-shifts`, {
      storeId,
      userId,
      startingCash: 100
    }, { headers });
    const shiftId = shift.data.id;

    console.log('8. Procesando Venta...');
    const sale = await axios.post(`${API_URL}/sales/process`, {
      storeId,
      cashShiftId: shiftId,
      cashierId: userId,
      ticketNumber: 'T1',
      paymentMethod: 'CASH',
      items: [{ productId, quantity: 5, unitPrice: 10 }]
    }, { headers });

    console.log('✅ TODO OK:', sale.data);

  } catch (e) {
    console.error('❌ ERROR:', e.response ? e.response.data : e.message);
  }
}

runSingleTest();
