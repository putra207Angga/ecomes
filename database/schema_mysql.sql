-- =========================================================
-- E-Comes Abel'z Handmade - MySQL / MariaDB Schema
-- File: database/schema_mysql.sql
-- Generated: 2026-09-16
-- =========================================================

CREATE DATABASE IF NOT EXISTS `ecomes_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `ecomes_db`;

-- 1. Users Table (Admin & Staff CS)
CREATE TABLE IF NOT EXISTS `users` (
    `id` VARCHAR(36) NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(150) NOT NULL UNIQUE,
    `password_hash` VARCHAR(255) NOT NULL,
    `role` VARCHAR(50) NOT NULL DEFAULT 'CS Support', -- 'Super Admin', 'Store Manager', 'CS Support'
    `avatar` VARCHAR(255) DEFAULT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Customers Table (Pembeli)
CREATE TABLE IF NOT EXISTS `customers` (
    `id` VARCHAR(36) NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(150) DEFAULT NULL,
    `phone` VARCHAR(25) NOT NULL,
    `level` VARCHAR(50) DEFAULT 'Regular', -- 'VIP Member', 'Regular'
    `total_orders` INT DEFAULT 0,
    `total_spent` DECIMAL(12, 2) DEFAULT 0.00,
    `avatar` VARCHAR(255) DEFAULT NULL,
    `address` TEXT DEFAULT NULL,
    `is_blocked` TINYINT(1) DEFAULT 0,
    `points` INT DEFAULT 100,
    `password_hash` VARCHAR(255) DEFAULT '123456',
    `registered_date` DATE DEFAULT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Categories Table
CREATE TABLE IF NOT EXISTS `categories` (
    `id` VARCHAR(36) NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `icon` VARCHAR(50) DEFAULT 'bi-box',
    `status` VARCHAR(20) DEFAULT 'Aktif',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Brands Table (Benang & Supplier)
CREATE TABLE IF NOT EXISTS `brands` (
    `id` VARCHAR(36) NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `logo` VARCHAR(255) DEFAULT NULL,
    `country` VARCHAR(100) DEFAULT 'Indonesia',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Products Table (Termasuk HPP & Profit Margin)
CREATE TABLE IF NOT EXISTS `products` (
    `id` VARCHAR(36) NOT NULL,
    `category_id` VARCHAR(36) DEFAULT NULL,
    `brand_id` VARCHAR(36) DEFAULT NULL,
    `name` VARCHAR(150) NOT NULL,
    `sku` VARCHAR(50) NOT NULL UNIQUE,
    `price` DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    `hpp` DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    `stock` INT NOT NULL DEFAULT 0,
    `image` VARCHAR(255) DEFAULT NULL,
    `status` VARCHAR(30) DEFAULT 'Aktif', -- 'Aktif', 'Menipis', 'Out of Stock'
    `description` TEXT DEFAULT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_products_category` (`category_id`),
    KEY `idx_products_brand` (`brand_id`),
    CONSTRAINT `fk_products_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_products_brand` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Orders Table (Pesanan Utam)
CREATE TABLE IF NOT EXISTS `orders` (
    `id` VARCHAR(36) NOT NULL,
    `order_no` VARCHAR(50) NOT NULL UNIQUE,
    `customer_id` VARCHAR(36) DEFAULT NULL,
    `customer_name` VARCHAR(100) NOT NULL,
    `customer_phone` VARCHAR(25) NOT NULL,
    `date` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `total` DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    `courier` VARCHAR(50) NOT NULL,
    `status` VARCHAR(30) DEFAULT 'Pending', -- 'Pending', 'Diproses', 'Dikirim', 'Selesai', 'Dibatalkan'
    `payment_method` VARCHAR(50) NOT NULL,
    `tracking_no` VARCHAR(100) DEFAULT '',
    `cancel_reason` TEXT DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_orders_customer` (`customer_id`),
    CONSTRAINT `fk_orders_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. Order Items Table (Detail Produk & Opsi Rajut Custom)
CREATE TABLE IF NOT EXISTS `order_items` (
    `id` VARCHAR(36) NOT NULL,
    `order_id` VARCHAR(36) NOT NULL,
    `product_id` VARCHAR(36) DEFAULT NULL,
    `product_name` VARCHAR(150) NOT NULL,
    `qty` INT NOT NULL DEFAULT 1,
    `price` DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    `custom_color` VARCHAR(100) DEFAULT '',
    `yarn_type` VARCHAR(100) DEFAULT '',
    `custom_notes` TEXT DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_order_items_order` (`order_id`),
    KEY `idx_order_items_product` (`product_id`),
    CONSTRAINT `fk_order_items_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_order_items_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. Transactions Table (Tabel Transaksi Pembayaran / Payment Gateway Log)
CREATE TABLE IF NOT EXISTS `transactions` (
    `id` VARCHAR(36) NOT NULL,
    `transaction_no` VARCHAR(100) NOT NULL UNIQUE,
    `order_id` VARCHAR(36) NOT NULL,
    `order_no` VARCHAR(50) NOT NULL,
    `customer_name` VARCHAR(100) NOT NULL,
    `payment_gateway` VARCHAR(50) NOT NULL, -- 'Midtrans', 'Xendit', 'Bank Transfer', 'COD'
    `payment_type` VARCHAR(50) NOT NULL, -- 'QRIS', 'BCA VA', 'GoPay', 'Manual'
    `gross_amount` DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    `transaction_status` VARCHAR(30) DEFAULT 'settlement', -- 'settlement', 'pending', 'deny', 'expire', 'refund'
    `gateway_transaction_id` VARCHAR(100) DEFAULT '',
    `snap_token` VARCHAR(255) DEFAULT '',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_transactions_order` (`order_id`),
    KEY `idx_transactions_no` (`transaction_no`),
    CONSTRAINT `fk_transactions_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. Reviews Table (Moderasi Review & Ulasan)
CREATE TABLE IF NOT EXISTS `reviews` (
    `id` VARCHAR(36) NOT NULL,
    `customer_id` VARCHAR(36) DEFAULT NULL,
    `product_id` VARCHAR(36) DEFAULT NULL,
    `customer_name` VARCHAR(100) NOT NULL,
    `product_title` VARCHAR(150) NOT NULL,
    `rating` INT NOT NULL CHECK (`rating` >= 1 AND `rating` <= 5),
    `comment` TEXT NOT NULL,
    `date` VARCHAR(20) NOT NULL,
    `reply_text` TEXT DEFAULT NULL,
    `status` VARCHAR(30) DEFAULT 'Perlu Balasan',
    `approval_status` VARCHAR(30) DEFAULT 'Disetujui',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_reviews_customer` (`customer_id`),
    KEY `idx_reviews_product` (`product_id`),
    CONSTRAINT `fk_reviews_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_reviews_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. Chat Messages Table (Pesan Live Chat & Balasan Admin)
CREATE TABLE IF NOT EXISTS `chat_messages` (
    `id` VARCHAR(36) NOT NULL,
    `contact_id` VARCHAR(100) NOT NULL,
    `user_id` VARCHAR(36) DEFAULT NULL,
    `sender` VARCHAR(100) NOT NULL,
    `text` TEXT NOT NULL,
    `time` VARCHAR(20) NOT NULL,
    `is_admin` TINYINT(1) DEFAULT 0,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_chat_messages_contact` (`contact_id`),
    KEY `idx_chat_messages_user` (`user_id`),
    CONSTRAINT `fk_chat_messages_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. Promos Table
CREATE TABLE IF NOT EXISTS `promos` (
    `id` VARCHAR(36) NOT NULL,
    `code` VARCHAR(50) NOT NULL UNIQUE,
    `discount_text` VARCHAR(100) NOT NULL,
    `min_purchase` DECIMAL(12, 2) DEFAULT 0.00,
    `max_discount` DECIMAL(12, 2) DEFAULT 50000.00,
    `quota` INT DEFAULT 100,
    `used` INT DEFAULT 0,
    `expired_date` DATE NOT NULL,
    `is_active` TINYINT(1) DEFAULT 1,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 11. Store Settings Table
CREATE TABLE IF NOT EXISTS `store_settings` (
    `id` INT NOT NULL DEFAULT 1,
    `store_name` VARCHAR(150) DEFAULT 'E-Comes Official Store',
    `phone` VARCHAR(50) DEFAULT '+62 812-3456-7890',
    `email` VARCHAR(150) DEFAULT 'support@ecomes.com',
    `address` TEXT DEFAULT NULL,
    `couriers` VARCHAR(255) DEFAULT 'JNE, Sicepat, GoSend, GrabExpress',
    `midtrans_key` VARCHAR(255) DEFAULT 'SB-Mid-server-xxxxxxxxxxxx',
    `xendit_key` VARCHAR(255) DEFAULT 'xnd_development_xxxxxxxxxxxx',
    `tax_rate` DECIMAL(5, 2) DEFAULT 11.00,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Initial Seed Data Admin
INSERT INTO `users` (`id`, `name`, `email`, `password_hash`, `role`, `avatar`) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Yayuk Wahyuni', 'yayuk@ecomes.com', '$2a$12$e0M2/qXGzYx1y1...', 'Super Admin', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'Budi Store Manager', 'budi@ecomes.com', '$2a$12$e0M2/qXGzYx1y1...', 'Store Manager', 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde')
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);
