
const axios = require('axios');

async function checkUsers() {
  const API_URL = 'http://localhost:3010/api';
  try {
    const testEmail = 'admin@multitienda.com';
    const testPassword = 'admin123';
    
    console.log(`Intentando registrar usuario: ${testEmail}...`);
    try {
      await axios.post(`${API_URL}/auth/register`, {
        email: testEmail,
        password: testPassword,
        name: 'Administrador de Pruebas',
        role: 'master-admin'
      });
      console.log('✅ Usuario registrado exitosamente.');
    } catch (e) {
      if (e.response && e.response.status === 409) {
        console.log('ℹ️ El usuario ya existe.');
      } else {
        console.error('Error al registrar:', e.message);
        if (e.response) console.error(e.response.data);
      }
    }
    
    console.log(`\nCredenciales para usar:`);
    console.log(`Usuario: ${testEmail}`);
    console.log(`Contraseña: ${testPassword}`);
    
  } catch (err) {
    console.error('❌ Error fatal:', err.message);
  }
}

checkUsers();
