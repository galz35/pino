const axios = require('axios');

const API_URL = 'http://localhost:3010/api';

async function testSyncBatch() {
  console.log('🔄 --- INICIANDO TEST DE BATCH SYNC (OFFLINE-FIRST) ---\n');

  try {
    // 1. Registro y Setup
    const auth = await axios.post(`${API_URL}/auth/register`, {
      email: `sync_tester_${Date.now()}@test.com`,
      password: 'password123',
      name: 'Sync Tester',
      role: 'master-admin'
    });
    const token = auth.data.accessToken;
    const userId = auth.data.user.id;
    const headers = { Authorization: `Bearer ${token}` };

    const chain = await axios.post(`${API_URL}/chains`, { name: 'Batch Chain' }, { headers });
    const store = await axios.post(`${API_URL}/stores`, { chainId: chain.data.id, name: 'Sincro Tienda' }, { headers });
    const storeId = store.data.id;

    const prod = await axios.post(`${API_URL}/products`, { 
      storeId, 
      description: 'Producto Sync', 
      salePrice: 100, 
      costPrice: 50,
      barcode: 'SYNC-001'
    }, { headers });
    const productId = prod.data.id;

    // Carga inicial
    await axios.post(`${API_URL}/inventory/adjust`, {
      storeId, productId, userId, type: 'IN', quantity: 50, reference: 'Initial'
    }, { headers });

    const shift = await axios.post(`${API_URL}/cash-shifts`, {
      storeId, userId, startingCash: 1000
    }, { headers });
    const shiftId = shift.data.id;

    // 2. SIMULAR BATCH OFFLINE (Payload que enviaría el Frontend al recuperar red)
    console.log('2. Enviando Carga Batch con 2 Ventas Offline...');
    const batchPayload = {
      storeId: storeId,
      operations: [
        {
          id: 'off-1',
          type: 'SALE',
          timestamp: new Date().toISOString(),
          data: {
            ticketNumber: 'OFF-101',
            cashShiftId: shiftId,
            cashierId: userId,
            subtotal: 100,
            tax: 15,
            total: 115,
            paymentMethod: 'CASH',
            items: [{ productId: productId, quantity: 1, unitPrice: 100 }]
          }
        },
        {
          id: 'off-2',
          type: 'SALE',
          timestamp: new Date().toISOString(),
          data: {
            ticketNumber: 'OFF-102',
            cashShiftId: shiftId,
            cashierId: userId,
            subtotal: 200,
            tax: 30,
            total: 230,
            paymentMethod: 'CASH',
            items: [{ productId: productId, quantity: 2, unitPrice: 100 }]
          }
        }
      ]
    };

    const syncRes = await axios.post(`${API_URL}/sync/batch`, batchPayload, { headers });
    console.log(`✅ Sincronización Exitosa: Procesadas ${syncRes.data.processed} operaciones.\n`);

    // 3. Validar resultados en BD
    const kardex = await axios.get(`${API_URL}/inventory/kardex?storeId=${storeId}&productId=${productId}`, { headers });
    console.log(`📊 Balance de Inventario: ${kardex.data[0].balance} unidades (Esperado: 47)`);
    
    const activeShift = await axios.get(`${API_URL}/cash-shifts/active?storeId=${storeId}`, { headers });
    console.log(`💰 Caja Actualizada: $${activeShift.data.actual_cash} (Esperado: $1345)`);

    if (kardex.data[0].balance == 47 && parseFloat(activeShift.data.actual_cash) == 1345) {
      console.log('\n🏁 --- TEST DE SINCRONIZACIÓN PASADO AL 100% --- 🏁');
    }

  } catch (e) {
    console.error('❌ ERROR EN BATCH SYNC:', e.response ? e.response.data : e.message);
  }
}

testSyncBatch();
