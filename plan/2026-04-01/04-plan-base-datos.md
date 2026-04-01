# 04 — Plan de Evolución de Base de Datos PostgreSQL

**Referencia:** Sección 17 del requerimiento.txt  
**Schema actual:** `sistema/backend/src/database/schema.sql` (266 líneas, 15 tablas)

---

## 1. Tablas Existentes en schema.sql

| # | Tabla | Estado |
|---|-------|--------|
| 1 | `chains` | ✅ OK |
| 2 | `stores` | ✅ OK |
| 3 | `users` | ✅ OK |
| 4 | `user_stores` | ✅ OK |
| 5 | `departments` | ✅ OK |
| 6 | `products` | ⚠️ Necesita columns bultos/unidades |
| 7 | `cash_shifts` | ✅ OK |
| 8 | `sales` | ✅ OK |
| 9 | `sale_items` | ✅ OK |
| 10 | `movements` | ⚠️ Necesita soporte bultos/unidades |
| 11 | `sync_logs` | ✅ OK |
| 12 | `clients` | ✅ OK |
| 13 | `suppliers` | ✅ OK |
| 14 | `orders` | ⚠️ Necesita payment_type, price_level |
| 15 | `order_items` | ⚠️ Necesita price_level, presentation |
| 16 | `zones` | ✅ OK |
| 17 | `sub_zones` | ✅ OK |
| 18 | `licenses` | ✅ OK |
| 19 | `invoices` | ✅ OK |
| 20 | `invoice_items` | ✅ OK |
| 21 | `config` | ✅ OK |

---

## 2. Tablas Faltantes en schema.sql (usadas por servicios pero sin DDL)

Estas tablas son referenciadas por servicios NestJS existentes pero NO están en schema.sql:

```sql
-- ============================================================
-- TABLAS FALTANTES QUE YA USA EL CÓDIGO PERO NO ESTÁN EN DDL
-- ============================================================

-- Inventario del Vendedor/Rutero
CREATE TABLE IF NOT EXISTS vendor_inventories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
    assigned_quantity INT DEFAULT 0,
    sold_quantity INT DEFAULT 0,
    current_quantity INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(vendor_id, product_id)
);

-- Cuentas por Cobrar
CREATE TABLE IF NOT EXISTS accounts_receivable (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
    client_id UUID REFERENCES clients(id) ON DELETE SET NULL,
    order_id UUID REFERENCES orders(id) ON DELETE SET NULL,
    total_amount DECIMAL(12, 2) NOT NULL,
    remaining_amount DECIMAL(12, 2) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Pagos de Cuentas por Cobrar
CREATE TABLE IF NOT EXISTS account_payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id UUID REFERENCES accounts_receivable(id) ON DELETE CASCADE,
    amount DECIMAL(12, 2) NOT NULL,
    payment_method VARCHAR(30) DEFAULT 'CASH',
    notes TEXT,
    collected_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Pedidos Pendientes (tabla separada de orders)
CREATE TABLE IF NOT EXISTS pending_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
    client_id UUID REFERENCES clients(id) ON DELETE SET NULL,
    client_name VARCHAR(150),
    items JSONB DEFAULT '[]',
    total DECIMAL(12, 2) DEFAULT 0,
    notes TEXT,
    payment_method VARCHAR(30) DEFAULT 'Efectivo',
    status VARCHAR(30) DEFAULT 'Pendiente',
    dispatched_by UUID REFERENCES users(id) ON DELETE SET NULL,
    dispatched_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Entregas Pendientes
CREATE TABLE IF NOT EXISTS pending_deliveries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
    order_id UUID REFERENCES orders(id) ON DELETE SET NULL,
    client_id UUID REFERENCES clients(id) ON DELETE SET NULL,
    client_name VARCHAR(150),
    rutero_id UUID REFERENCES users(id) ON DELETE SET NULL,
    address TEXT,
    notes TEXT,
    status VARCHAR(30) DEFAULT 'Pendiente',
    route_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 3. Tablas NUEVAS Requeridas por el Requerimiento

```sql
-- ============================================================
-- TABLAS NUEVAS — REQUERIDAS POR requerimiento.txt
-- ============================================================

-- -----------------------------------------------
-- 3.1 Devoluciones (sección 6.6, 15)
-- -----------------------------------------------
CREATE TABLE IF NOT EXISTS returns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
    order_id UUID REFERENCES orders(id) ON DELETE SET NULL,
    rutero_id UUID REFERENCES users(id) ON DELETE SET NULL,
    notes TEXT,
    total DECIMAL(12, 2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS return_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    return_id UUID REFERENCES returns(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    quantity_bulks INT DEFAULT 0,
    quantity_units INT DEFAULT 0,
    unit_price DECIMAL(12, 2) DEFAULT 0,
    subtotal DECIMAL(12, 2) DEFAULT 0
);

-- -----------------------------------------------
-- 3.2 Cobros del Rutero (sección 6.5, 14)
-- -----------------------------------------------
CREATE TABLE IF NOT EXISTS collections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
    account_id UUID REFERENCES accounts_receivable(id) ON DELETE SET NULL,
    rutero_id UUID REFERENCES users(id) ON DELETE SET NULL,
    client_id UUID REFERENCES clients(id) ON DELETE SET NULL,
    amount DECIMAL(12, 2) NOT NULL,
    payment_method VARCHAR(30) DEFAULT 'CASH',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_collections_rutero_date 
    ON collections(rutero_id, created_at);

-- -----------------------------------------------
-- 3.3 Cuentas por Pagar (sección 12.3)
-- -----------------------------------------------
CREATE TABLE IF NOT EXISTS accounts_payable (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
    supplier_id UUID REFERENCES suppliers(id) ON DELETE SET NULL,
    invoice_id UUID REFERENCES invoices(id) ON DELETE SET NULL,
    total_amount DECIMAL(12, 2) NOT NULL,
    remaining_amount DECIMAL(12, 2) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'PENDING',
    due_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS payable_payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id UUID REFERENCES accounts_payable(id) ON DELETE CASCADE,
    amount DECIMAL(12, 2) NOT NULL,
    payment_method VARCHAR(30) DEFAULT 'TRANSFER',
    notes TEXT,
    paid_by UUID REFERENCES users(id) ON DELETE SET NULL,
    paid_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------
-- 3.4 Cierre de Caja del Rutero (sección 14.3)
-- Nota: No inventar estructura, solo persistir lo que existe en Flutter
-- -----------------------------------------------
CREATE TABLE IF NOT EXISTS daily_closings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
    rutero_id UUID REFERENCES users(id) ON DELETE SET NULL,
    total_sales DECIMAL(12, 2) DEFAULT 0,
    total_collections DECIMAL(12, 2) DEFAULT 0,
    total_returns DECIMAL(12, 2) DEFAULT 0,
    cash_total DECIMAL(12, 2) DEFAULT 0,
    closing_date DATE NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------
-- 3.5 Rutas formales (sección 13)
-- Ya existe tabla en routes.service pero sin DDL formal
-- -----------------------------------------------
CREATE TABLE IF NOT EXISTS vendor_routes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
    vendor_id UUID REFERENCES users(id) ON DELETE SET NULL,
    client_ids JSONB DEFAULT '[]',
    route_date DATE,
    status VARCHAR(30) DEFAULT 'PLANNED',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 4. Alteraciones a Tablas Existentes

```sql
-- ============================================================
-- ALTER TABLE — Extensiones a tablas existentes
-- ============================================================

-- 4.1 Productos: Bultos y Unidades (sección 10)
ALTER TABLE products ADD COLUMN IF NOT EXISTS units_per_bulk INT DEFAULT 1;
ALTER TABLE products ADD COLUMN IF NOT EXISTS stock_bulks INT DEFAULT 0;
ALTER TABLE products ADD COLUMN IF NOT EXISTS stock_units INT DEFAULT 0;

-- 4.2 Pedidos: Tipo de pago y nivel de precio (secciones 7.1, 11)
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_type VARCHAR(20) DEFAULT 'CONTADO';
ALTER TABLE orders ADD COLUMN IF NOT EXISTS price_level INT DEFAULT 1;

-- 4.3 Items de pedido: Presentación
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS presentation VARCHAR(10) DEFAULT 'UNIT';
-- UNIT = unidades, BULK = bultos
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS price_level INT DEFAULT 1;

-- 4.4 Movimientos: Bultos y Unidades
ALTER TABLE movements ADD COLUMN IF NOT EXISTS quantity_bulks INT DEFAULT 0;
ALTER TABLE movements ADD COLUMN IF NOT EXISTS quantity_units INT DEFAULT 0;
ALTER TABLE movements ADD COLUMN IF NOT EXISTS balance_bulks INT DEFAULT 0;
ALTER TABLE movements ADD COLUMN IF NOT EXISTS balance_units INT DEFAULT 0;

-- 4.5 Vendor inventories: Bultos y Unidades
ALTER TABLE vendor_inventories ADD COLUMN IF NOT EXISTS assigned_bulks INT DEFAULT 0;
ALTER TABLE vendor_inventories ADD COLUMN IF NOT EXISTS assigned_units INT DEFAULT 0;
ALTER TABLE vendor_inventories ADD COLUMN IF NOT EXISTS current_bulks INT DEFAULT 0;
ALTER TABLE vendor_inventories ADD COLUMN IF NOT EXISTS current_units INT DEFAULT 0;

-- 4.6 Índices de performance
CREATE INDEX IF NOT EXISTS idx_returns_store ON returns(store_id);
CREATE INDEX IF NOT EXISTS idx_returns_rutero ON returns(rutero_id);
CREATE INDEX IF NOT EXISTS idx_accounts_payable_store ON accounts_payable(store_id);
CREATE INDEX IF NOT EXISTS idx_daily_closings_rutero ON daily_closings(rutero_id, closing_date);
CREATE INDEX IF NOT EXISTS idx_vendor_inventories_vendor ON vendor_inventories(vendor_id);
```

---

## 5. Migración Segura

Orden de ejecución seguro para la migración:

1. **Primero:** Tablas faltantes del código existente (sección 2)
2. **Segundo:** Tablas nuevas (sección 3)  
3. **Tercero:** ALTER TABLEs (sección 4)
4. **Cuarto:** Índices de performance

Todos los ALTER usan `IF NOT EXISTS` / `ADD COLUMN IF NOT EXISTS` para ser idempotentes.

**Total de tablas después de migración: ~30 tablas**
