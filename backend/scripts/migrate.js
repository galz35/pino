const { Client } = require('pg');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

async function run() {
  const client = new Client({
    host: process.env.DATABASE_HOST,
    port: process.env.DATABASE_PORT,
    user: process.env.DATABASE_USER,
    password: process.env.DATABASE_PASSWORD,
    database: process.env.DATABASE_NAME,
  });

  try {
    await client.connect();
    console.log('✅ Conectado a la base de datos PostgreSQL.');

    const sqlPath = path.join(__dirname, '../src/database/schema.sql');
    const sql = fs.readFileSync(sqlPath, 'utf8');

    console.log('⏳ Ejecutando schema.sql...');
    await client.query(sql);

    console.log('🚀 Tablas y columnas creadas/actualizadas exitosamente.');
  } catch (error) {
    console.error('❌ Error ejecutando SQL:', error);
  } finally {
    await client.end();
  }
}

run();
