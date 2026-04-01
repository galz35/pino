-- =============================================================
-- MIGRACIÓN: Tablas para módulos Vendors/Deliveries/Monitor
-- Fecha: 2026-03-31
-- Descripción: Crea las tablas faltantes que los nuevos módulos
--              NestJS necesitan para funcionar correctamente.
-- =============================================================

-- 1. Store Zones (zonas a nivel tienda para vendedores)
CREATE TABLE IF NOT EXISTS store_zones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  color VARCHAR(20),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_store_zones_store ON store_zones(store_id);

-- 2. Visit Logs (registros de visitas de vendedores)
CREATE TABLE IF NOT EXISTS visit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  vendor_id UUID NOT NULL REFERENCES users(id),
  client_id UUID REFERENCES clients(id),
  notes TEXT,
  latitude DECIMAL(10, 7),
  longitude DECIMAL(10, 7),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_visit_logs_store ON visit_logs(store_id);
CREATE INDEX IF NOT EXISTS idx_visit_logs_vendor ON visit_logs(vendor_id);

-- 3. Vendor Inventories (inventario asignado a vendedores)
CREATE TABLE IF NOT EXISTS vendor_inventories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vendor_id UUID NOT NULL REFERENCES users(id),
  product_id UUID NOT NULL REFERENCES products(id),
  store_id UUID NOT NULL REFERENCES stores(id),
  assigned_quantity INTEGER DEFAULT 0,
  sold_quantity INTEGER DEFAULT 0,
  current_quantity INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(vendor_id, product_id)
);
CREATE INDEX IF NOT EXISTS idx_vendor_inv_vendor ON vendor_inventories(vendor_id);

-- 4. Accounts Receivable (cuentas por cobrar)
CREATE TABLE IF NOT EXISTS accounts_receivable (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  client_id UUID REFERENCES clients(id),
  order_id UUID,
  total_amount DECIMAL(12, 2) NOT NULL DEFAULT 0,
  remaining_amount DECIMAL(12, 2) NOT NULL DEFAULT 0,
  description TEXT,
  status VARCHAR(20) DEFAULT 'PENDING',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_acc_recv_store ON accounts_receivable(store_id);
CREATE INDEX IF NOT EXISTS idx_acc_recv_client ON accounts_receivable(client_id);

-- 5. Account Payments (pagos a cuentas por cobrar)
CREATE TABLE IF NOT EXISTS account_payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id UUID NOT NULL REFERENCES accounts_receivable(id) ON DELETE CASCADE,
  amount DECIMAL(12, 2) NOT NULL,
  payment_method VARCHAR(20) DEFAULT 'CASH',
  notes TEXT,
  collected_by VARCHAR(100),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_acc_pay_account ON account_payments(account_id);

-- 6. Pending Deliveries (entregas pendientes)
CREATE TABLE IF NOT EXISTS pending_deliveries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  order_id UUID,
  client_id UUID REFERENCES clients(id),
  rutero_id UUID REFERENCES users(id),
  address TEXT,
  notes TEXT,
  status VARCHAR(30) DEFAULT 'Pendiente',
  route_date DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_pend_del_store ON pending_deliveries(store_id);
CREATE INDEX IF NOT EXISTS idx_pend_del_rutero ON pending_deliveries(rutero_id);

-- 7. Routes (rutas de vendedores)
CREATE TABLE IF NOT EXISTS routes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  vendor_id UUID NOT NULL REFERENCES users(id),
  client_ids JSONB DEFAULT '[]',
  route_date DATE,
  notes TEXT,
  status VARCHAR(20) DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_routes_store ON routes(store_id);
CREATE INDEX IF NOT EXISTS idx_routes_vendor ON routes(vendor_id);

-- 8. Pending Orders / Dispatcher (pedidos para despacho)
CREATE TABLE IF NOT EXISTS pending_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  client_id UUID REFERENCES clients(id),
  client_name VARCHAR(200),
  items JSONB DEFAULT '[]',
  total DECIMAL(12, 2) DEFAULT 0,
  notes TEXT,
  payment_method VARCHAR(30) DEFAULT 'Efectivo',
  status VARCHAR(30) DEFAULT 'Pendiente',
  dispatched_by VARCHAR(100),
  dispatched_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_pend_ord_store ON pending_orders(store_id);

-- 9. Error Logs (monitor de errores del sistema)
CREATE TABLE IF NOT EXISTS error_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message TEXT NOT NULL,
  stack TEXT,
  location VARCHAR(200),
  user_id UUID,
  store_id UUID,
  additional_info JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_error_logs_date ON error_logs(created_at DESC);

-- 10. Agregar columnas extras a sales (si no existen)
DO $$ BEGIN
  ALTER TABLE sales ADD COLUMN IF NOT EXISTS client_id UUID;
  ALTER TABLE sales ADD COLUMN IF NOT EXISTS client_name VARCHAR(200);
  ALTER TABLE sales ADD COLUMN IF NOT EXISTS cashier_name VARCHAR(200);
  ALTER TABLE sales ADD COLUMN IF NOT EXISTS payment_currency VARCHAR(10) DEFAULT 'NIO';
  ALTER TABLE sales ADD COLUMN IF NOT EXISTS amount_received DECIMAL(12, 2) DEFAULT 0;
  ALTER TABLE sales ADD COLUMN IF NOT EXISTS change_given DECIMAL(12, 2) DEFAULT 0;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- 11. Agregar parent_id a departments (para sub-departamentos)
DO $$ BEGIN
  ALTER TABLE departments ADD COLUMN IF NOT EXISTS parent_id UUID REFERENCES departments(id);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
