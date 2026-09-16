-- =========================================================
-- E-Comes Abel'z Handmade - PostgreSQL / Supabase Schema
-- File: database/schema_postgresql.sql
-- Generated: 2026-09-16
-- =========================================================

-- Extension for UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Users Table (Admin & CS Staff)
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'CS Support', -- 'Super Admin', 'Store Manager', 'CS Support'
    avatar VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Customers Table (Pembeli)
CREATE TABLE IF NOT EXISTS customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150),
    phone VARCHAR(25) NOT NULL,
    level VARCHAR(50) DEFAULT 'Regular', -- 'VIP Member', 'Regular'
    total_orders INT DEFAULT 0,
    total_spent DECIMAL(12, 2) DEFAULT 0.00,
    avatar VARCHAR(255),
    address TEXT,
    is_blocked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Categories Table
CREATE TABLE IF NOT EXISTS categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    icon VARCHAR(50) DEFAULT 'bi-box',
    status VARCHAR(20) DEFAULT 'Aktif'
);

-- 4. Brands Table (Benang & Supplier)
CREATE TABLE IF NOT EXISTS brands (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    logo VARCHAR(255),
    country VARCHAR(100) DEFAULT 'Indonesia'
);

-- 5. Products Table (Termasuk HPP & Margin Profit)
CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    brand_id UUID REFERENCES brands(id) ON DELETE SET NULL,
    name VARCHAR(150) NOT NULL,
    sku VARCHAR(50) UNIQUE NOT NULL,
    price DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    hpp DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    stock INT NOT NULL DEFAULT 0,
    image VARCHAR(255),
    status VARCHAR(30) DEFAULT 'Aktif', -- 'Aktif', 'Menipis', 'Out of Stock'
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. Orders Table (Transaksi Utam)
CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_no VARCHAR(50) UNIQUE NOT NULL,
    customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,
    customer_name VARCHAR(100) NOT NULL,
    customer_phone VARCHAR(25) NOT NULL,
    date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    courier VARCHAR(50) NOT NULL,
    status VARCHAR(30) DEFAULT 'Pending', -- 'Pending', 'Diproses', 'Dikirim', 'Selesai', 'Dibatalkan'
    payment_method VARCHAR(50) NOT NULL,
    tracking_no VARCHAR(100) DEFAULT '',
    cancel_reason TEXT DEFAULT ''
);

-- 7. Order Items Table (Termasuk Pilihan Warna Custom & Jenis Benang)
CREATE TABLE IF NOT EXISTS order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    product_name VARCHAR(150) NOT NULL,
    qty INT NOT NULL DEFAULT 1,
    price DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    custom_color VARCHAR(100) DEFAULT '',
    yarn_type VARCHAR(100) DEFAULT '',
    custom_notes TEXT DEFAULT ''
);

-- 8. Transactions Table (Tabel Transaksi Pembayaran / Payment Gateway Log)
CREATE TABLE IF NOT EXISTS transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transaction_no VARCHAR(100) UNIQUE NOT NULL, -- Contoh: TRX-20260916-001
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    order_no VARCHAR(50) NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    payment_gateway VARCHAR(50) NOT NULL, -- 'Midtrans', 'Xendit', 'Bank Transfer', 'COD'
    payment_type VARCHAR(50) NOT NULL, -- 'QRIS', 'BCA VA', 'GoPay', 'Manual'
    gross_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    transaction_status VARCHAR(30) DEFAULT 'settlement', -- 'settlement', 'pending', 'deny', 'expire', 'refund'
    gateway_transaction_id VARCHAR(100) DEFAULT '',
    snap_token VARCHAR(255) DEFAULT '',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 8. Reviews Table (Moderasi Review Pembeli & Balasan Admin)
CREATE TABLE IF NOT EXISTS reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    customer_name VARCHAR(100) NOT NULL,
    product_title VARCHAR(150) NOT NULL,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    comment TEXT NOT NULL,
    date VARCHAR(20) NOT NULL,
    reply_text TEXT DEFAULT '',
    status VARCHAR(30) DEFAULT 'Perlu Balasan', -- 'Perlu Balasan', 'Dibalas'
    approval_status VARCHAR(30) DEFAULT 'Disetujui', -- 'Disetujui', 'Menunggu Moderasi', 'Ditolak'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 9. Chat Messages Table (Live Chat Pembeli <-> Admin CS)
CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contact_id VARCHAR(100) NOT NULL, -- Customer ID / Session ID
    user_id UUID REFERENCES users(id) ON DELETE SET NULL, -- ID User Admin (jika balasan dari admin)
    sender VARCHAR(100) NOT NULL,
    text TEXT NOT NULL,
    time VARCHAR(20) NOT NULL,
    is_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 10. Promos Table
CREATE TABLE IF NOT EXISTS promos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(50) UNIQUE NOT NULL,
    discount_text VARCHAR(100) NOT NULL,
    min_purchase DECIMAL(12, 2) DEFAULT 0.00,
    max_discount DECIMAL(12, 2) DEFAULT 50000.00,
    quota INT DEFAULT 100,
    used INT DEFAULT 0,
    expired_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- 11. Store Settings Table
CREATE TABLE IF NOT EXISTS store_settings (
    id INT PRIMARY KEY DEFAULT 1,
    store_name VARCHAR(150) DEFAULT 'E-Comes Official Store',
    phone VARCHAR(50) DEFAULT '+62 812-3456-7890',
    email VARCHAR(150) DEFAULT 'support@ecomes.com',
    address TEXT DEFAULT 'Jl. Raya Sudirman No. 123, Jakarta Selatan',
    couriers VARCHAR(255) DEFAULT 'JNE, Sicepat, GoSend, GrabExpress',
    midtrans_key VARCHAR(255) DEFAULT 'SB-Mid-server-xxxxxxxxxxxx',
    xendit_key VARCHAR(255) DEFAULT 'xnd_development_xxxxxxxxxxxx',
    tax_rate DECIMAL(5, 2) DEFAULT 11.00
);

-- Indexing for high performance
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_orders_customer ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_order_no ON orders(order_no);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_contact ON chat_messages(contact_id);

-- Initial Seed Data Demo Users
INSERT INTO users (id, name, email, password_hash, role, avatar)
VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Yayuk Wahyuni', 'yayuk@ecomes.com', '$2a$12$e0M2/qXGzYx1y1...', 'Super Admin', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'Budi Store Manager', 'budi@ecomes.com', '$2a$12$e0M2/qXGzYx1y1...', 'Store Manager', 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde')
ON CONFLICT (email) DO NOTHING;
