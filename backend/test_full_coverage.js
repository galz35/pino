const axios = require('axios');

const API_URL = 'http://localhost:3010/api';

async function testFullCoverage() {
  console.log('🧪 --- INICIANDO TEST DE COBERTURA TOTAL DE APIs (CRUIDs) ---\n');

  try {
    // 1. Auth & Token
    const auth = await axios.post(`${API_URL}/auth/register`, {
      email: `coverage_${Date.now()}@test.com`,
      password: 'password123',
      name: 'Tester Cobertura',
      role: 'master-admin'
    });
    const token = auth.data.accessToken;
    const userId = auth.data.user.id;
    const headers = { Authorization: `Bearer ${token}` };

    // 2. Probar API de Usuarios (CRUD)
    console.log('1. Testeando API Users...');
    const users = await axios.get(`${API_URL}/users`, { headers });
    console.log(`✅ Listar usuarios: ${users.data.length} encontrados.`);
    
    await axios.patch(`${API_URL}/users/${userId}`, { name: 'Tester Actualizado' }, { headers });
    console.log('✅ Actualizar usuario exitoso.');

    // 3. Probar API de Clientes
    console.log('\n2. Testeando API Clients...');
    const chain = await axios.post(`${API_URL}/chains`, { name: 'Chain Test' }, { headers });
    const store = await axios.post(`${API_URL}/stores`, { chainId: chain.data.id, name: 'Tienda Test' }, { headers });
    const storeId = store.data.id;

    const clientRes = await axios.post(`${API_URL}/clients`, {
      storeId,
      name: 'Juan Perez',
      email: 'juan@gmail.com',
      phone: '12345678'
    }, { headers });
    const clientId = clientRes.data.id;
    console.log(`✅ Cliente creado: ${clientId}`);

    const clientsList = await axios.get(`${API_URL}/clients?storeId=${storeId}`, { headers });
    console.log(`✅ Listar clientes: ${clientsList.data.length} encontrado.`);

    // 4. Probar API de Proveedores
    console.log('\n3. Testeando API Suppliers...');
    const supplierRes = await axios.post(`${API_URL}/suppliers`, {
      chainId: chain.data.id,
      name: 'Proveedor Global S.A.',
      contactName: 'Carlos Ruiz'
    }, { headers });
    const supplierId = supplierRes.data.id;
    console.log(`✅ Proveedor creado: ${supplierId}`);

    const suppliersList = await axios.get(`${API_URL}/suppliers?chainId=${chain.data.id}`, { headers });
    console.log(`✅ Listar proveedores: ${suppliersList.data.length} encontrado.`);

    // 5. Probar API de Productos (Búsqueda)
    console.log('\n4. Testeando Búsquedas de Productos...');
    await axios.post(`${API_URL}/products`, {
      storeId,
      description: 'Coca Cola 12oz',
      barcode: '775001',
      salePrice: 15,
      costPrice: 10
    }, { headers });

    const searchRes = await axios.get(`${API_URL}/products?storeId=${storeId}&search=Coca`, { headers });
    console.log(`✅ Búsqueda por texto (Coca): ${searchRes.data.length} resultados.`);
    
    const barcodeRes = await axios.get(`${API_URL}/products/barcode/775001?storeId=${storeId}`, { headers });
    console.log(`✅ Búsqueda por código de barras (775001): ${barcodeRes.data.description}`);

    console.log('\n🏁 --- TODOS LOS MÓDULOS DE API ESTÁN ACTIVOS Y FUNCIONALES --- 🏁');

  } catch (e) {
    console.error('❌ FALLO EN TEST DE COBERTURA:');
    console.error(e.response ? e.response.data : e.message);
    process.exit(1);
  }
}

testFullCoverage();
