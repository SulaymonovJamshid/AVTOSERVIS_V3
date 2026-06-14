-- AvtoGram Database Schema
-- MySQL 8.0+
-- Encoding: utf8mb4

CREATE DATABASE IF NOT EXISTS avtogram_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE avtogram_db;

-- ─── Users ────────────────────────────────────────────────────────────────────
CREATE TABLE users (
    id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(150)        NOT NULL,
    phone      VARCHAR(20)         NOT NULL UNIQUE,
    email      VARCHAR(150)                 DEFAULT NULL,
    password   VARCHAR(255)        NOT NULL,
    role       ENUM('user','owner','admin') DEFAULT 'user',
    avatar     VARCHAR(500)                 DEFAULT NULL,
    is_blocked TINYINT(1)                   DEFAULT 0,
    created_at DATETIME            NOT NULL,
    updated_at DATETIME                     DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ─── Services ────────────────────────────────────────────────────────────────
CREATE TABLE services (
    id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    owner_id      INT UNSIGNED        NOT NULL,
    name          VARCHAR(200)        NOT NULL,
    description   TEXT,
    address       VARCHAR(400)        NOT NULL,
    city          VARCHAR(100)        NOT NULL,
    district      VARCHAR(100)                 DEFAULT '',
    lat           DECIMAL(10,7)       NOT NULL DEFAULT 0,
    lng           DECIMAL(10,7)       NOT NULL DEFAULT 0,
    phone         VARCHAR(20)         NOT NULL,
    logo          VARCHAR(500)                 DEFAULT NULL,
    images        JSON,
    categories    JSON,
    working_hours VARCHAR(50)                  DEFAULT '09:00 - 18:00',
    is_open       TINYINT(1)                   DEFAULT 1,
    is_active     TINYINT(1)                   DEFAULT 1,
    is_verified   TINYINT(1)                   DEFAULT 0,
    created_at    DATETIME            NOT NULL,
    updated_at    DATETIME                     DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_city (city),
    INDEX idx_lat_lng (lat, lng),
    FULLTEXT INDEX ft_name_addr (name, address)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ─── Reviews ─────────────────────────────────────────────────────────────────
CREATE TABLE reviews (
    id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id    INT UNSIGNED NOT NULL,
    service_id INT UNSIGNED NOT NULL,
    rating     TINYINT      NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment    TEXT         NOT NULL,
    created_at DATETIME     NOT NULL,
    UNIQUE KEY uq_user_service (user_id, service_id),
    FOREIGN KEY (user_id)    REFERENCES users(id)    ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ─── Bookings ────────────────────────────────────────────────────────────────
CREATE TABLE bookings (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     INT UNSIGNED NOT NULL,
    service_id  INT UNSIGNED NOT NULL,
    car_model   VARCHAR(150) NOT NULL,
    description TEXT         NOT NULL,
    status      ENUM('pending','accepted','in_progress','completed','cancelled')
                             NOT NULL DEFAULT 'pending',
    date        DATETIME     NOT NULL,
    created_at  DATETIME     NOT NULL,
    FOREIGN KEY (user_id)    REFERENCES users(id)    ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
    INDEX idx_user   (user_id),
    INDEX idx_service (service_id),
    INDEX idx_status  (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ─── Parts ───────────────────────────────────────────────────────────────────
CREATE TABLE parts (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    seller_id   INT UNSIGNED   NOT NULL,
    name        VARCHAR(200)   NOT NULL,
    description TEXT,
    price       DECIMAL(12,2)  NOT NULL DEFAULT 0,
    image       VARCHAR(500)            DEFAULT NULL,
    car_brand   VARCHAR(100)            DEFAULT '',
    car_model   VARCHAR(100)            DEFAULT '',
    in_stock    TINYINT(1)              DEFAULT 1,
    created_at  DATETIME       NOT NULL,
    FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE CASCADE,
    FULLTEXT INDEX ft_parts_name (name, description)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ─── Favorites ───────────────────────────────────────────────────────────────
CREATE TABLE favorites (
    id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id    INT UNSIGNED NOT NULL,
    service_id INT UNSIGNED NOT NULL,
    created_at DATETIME     NOT NULL,
    UNIQUE KEY uq_fav (user_id, service_id),
    FOREIGN KEY (user_id)    REFERENCES users(id)    ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ─── Seed: demo data ─────────────────────────────────────────────────────────
INSERT INTO users (name, phone, password, role, created_at) VALUES
  ('Test User',    '+998901234567', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user',  NOW()),
  ('Servis Egasi', '+998907654321', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'owner', NOW()),
  ('Admin',        '+998991111111', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', NOW());
-- Default parol: "password"

INSERT INTO services (owner_id, name, description, address, city, district, lat, lng, phone, working_hours, categories, images, is_active, is_verified, created_at) VALUES
(2, 'AutoPro Service',  'Professional avtoservis markazi', 'Yunusobod tumani, 7-mavze', 'Toshkent', 'Yunusobod', 41.3111, 69.2797, '+998901112233', '09:00 - 20:00', '["oil","tire","electric"]', '[]', 1, 1, NOW()),
(2, 'SpeedFix Motors',  'Tez va sifatli xizmat',           'Chilonzor tumani, 9-mavze', 'Toshkent', 'Chilonzor', 41.2825, 69.2052, '+998901112244', '08:00 - 21:00', '["body","wash","diag"]',    '[]', 1, 1, NOW()),
(2, 'MasterGaraj',      'Tajribali mexaniklar',            'Mirobod tumani',            'Toshkent', 'Mirobod',  41.3000, 69.2900, '+998901112255', '09:00 - 18:00', '["oil","diag"]',             '[]', 1, 0, NOW());
