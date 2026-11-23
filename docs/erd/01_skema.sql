
-- =====================================================
-- DATABASE : KOSKITA
-- DESKRIPSI: Sistem Informasi Manajemen Properti Kos
-- JUMLAH TABEL: 18
-- =====================================================

CREATE DATABASE IF NOT EXISTS koskita;
USE koskita;

-- =====================================================
-- 1. TABEL ROLES
-- =====================================================

CREATE TABLE roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    nama_role VARCHAR(50) NOT NULL,
    CONSTRAINT uq_roles_nama UNIQUE (nama_role)
) ENGINE=InnoDB;

-- =====================================================
-- 2. TABEL USERS
-- =====================================================

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    role_id INT NOT NULL,
    nama VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL,

    CONSTRAINT uq_users_email UNIQUE (email),

    CONSTRAINT fk_users_roles
        FOREIGN KEY (role_id)
        REFERENCES roles(role_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =====================================================
-- 3. TABEL PROPERTIES
-- =====================================================

CREATE TABLE properties (
    property_id INT AUTO_INCREMENT PRIMARY KEY,
    nama_properti VARCHAR(100) NOT NULL,
    alamat TEXT NOT NULL,
    kota VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'aktif',

    CONSTRAINT chk_properties_status
        CHECK (status IN ('aktif', 'nonaktif'))
) ENGINE=InnoDB;

-- =====================================================
-- 4. TABEL ROOM_TYPES
-- =====================================================

CREATE TABLE room_types (
    room_type_id INT AUTO_INCREMENT PRIMARY KEY,
    nama_tipe VARCHAR(50) NOT NULL,
    deskripsi TEXT
) ENGINE=InnoDB;

-- =====================================================
-- 5. TABEL FACILITIES
-- =====================================================

CREATE TABLE facilities (
    facility_id INT AUTO_INCREMENT PRIMARY KEY,
    nama_fasilitas VARCHAR(100) NOT NULL,
    deskripsi TEXT
) ENGINE=InnoDB;

-- =====================================================
-- 6. TABEL INVENTORY_ITEMS
-- =====================================================

CREATE TABLE inventory_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    nama_barang VARCHAR(100) NOT NULL,
    satuan VARCHAR(30) NOT NULL,
    deskripsi TEXT
) ENGINE=InnoDB;

-- =====================================================
-- 7. TABEL EMPLOYEES
-- =====================================================

CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    property_id INT NOT NULL,
    nomor_karyawan VARCHAR(30) NOT NULL,
    jabatan VARCHAR(50) NOT NULL,
    tanggal_bergabung DATE,

    CONSTRAINT uq_employees_user UNIQUE (user_id),
    CONSTRAINT uq_employees_nomor UNIQUE (nomor_karyawan),

    CONSTRAINT fk_employees_users
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_employees_properties
        FOREIGN KEY (property_id)
        REFERENCES properties(property_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =====================================================
-- 8. TABEL TENANTS
-- =====================================================

CREATE TABLE tenants (
    tenant_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    nomor_identitas VARCHAR(50) NOT NULL,
    nomor_telepon VARCHAR(20),
    alamat TEXT,

    CONSTRAINT uq_tenants_user UNIQUE (user_id),
    CONSTRAINT uq_tenants_identitas UNIQUE (nomor_identitas),

    CONSTRAINT fk_tenants_users
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =====================================================
-- 9. TABEL ROOMS
-- =====================================================

CREATE TABLE rooms (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    property_id INT NOT NULL,
    room_type_id INT NOT NULL,
    nomor_kamar VARCHAR(20) NOT NULL,
    harga_sewa DECIMAL(12,2) NOT NULL,
    status_kamar VARCHAR(20) NOT NULL DEFAULT 'tersedia',

    CONSTRAINT uq_rooms_nomor
        UNIQUE (property_id, nomor_kamar),

    CONSTRAINT chk_rooms_harga
        CHECK (harga_sewa > 0),

    CONSTRAINT chk_rooms_status
        CHECK (status_kamar IN ('tersedia', 'terisi', 'perbaikan')),

    CONSTRAINT fk_rooms_properties
        FOREIGN KEY (property_id)
        REFERENCES properties(property_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_rooms_room_types
        FOREIGN KEY (room_type_id)
        REFERENCES room_types(room_type_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =====================================================
-- 10. TABEL ROOM_FACILITIES
-- =====================================================

CREATE TABLE room_facilities (
    room_id INT NOT NULL,
    facility_id INT NOT NULL,

    PRIMARY KEY (room_id, facility_id),

    CONSTRAINT fk_room_facilities_rooms
        FOREIGN KEY (room_id)
        REFERENCES rooms(room_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_room_facilities_facilities
        FOREIGN KEY (facility_id)
        REFERENCES facilities(facility_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =====================================================
-- 11. TABEL RENTALS
-- =====================================================

CREATE TABLE rentals (
    rental_id INT AUTO_INCREMENT PRIMARY KEY,
    tenant_id INT NOT NULL,
    room_id INT NOT NULL,
    tanggal_mulai DATE NOT NULL,
    tanggal_selesai DATE,
    harga_sewa DECIMAL(12,2) NOT NULL,
    status_sewa VARCHAR(20) NOT NULL DEFAULT 'aktif',

    CONSTRAINT chk_rentals_harga
        CHECK (harga_sewa > 0),

    CONSTRAINT chk_rentals_tanggal
        CHECK (
            tanggal_selesai IS NULL
            OR tanggal_selesai >= tanggal_mulai
        ),

    CONSTRAINT chk_rentals_status
        CHECK (status_sewa IN ('aktif', 'selesai', 'dibatalkan')),

    CONSTRAINT fk_rentals_tenants
        FOREIGN KEY (tenant_id)
        REFERENCES tenants(tenant_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_rentals_rooms
        FOREIGN KEY (room_id)
        REFERENCES rooms(room_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =====================================================
-- 12. TABEL CONTRACTS
-- =====================================================

CREATE TABLE contracts (
    contract_id INT AUTO_INCREMENT PRIMARY KEY,
    rental_id INT NOT NULL,
    nomor_kontrak VARCHAR(50) NOT NULL,
    tanggal_kontrak DATE NOT NULL,
    file_kontrak VARCHAR(255),

    CONSTRAINT uq_contracts_rental UNIQUE (rental_id),
    CONSTRAINT uq_contracts_nomor UNIQUE (nomor_kontrak),

    CONSTRAINT fk_contracts_rentals
        FOREIGN KEY (rental_id)
        REFERENCES rentals(rental_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =====================================================
-- 13. TABEL INVOICES
-- =====================================================

CREATE TABLE invoices (
    invoice_id INT AUTO_INCREMENT PRIMARY KEY,
    rental_id INT NOT NULL,
    nomor_tagihan VARCHAR(50) NOT NULL,
    periode_tagihan DATE NOT NULL,
    tanggal_jatuh_tempo DATE NOT NULL,
    total_tagihan DECIMAL(12,2) NOT NULL,
    status_tagihan VARCHAR(20) NOT NULL DEFAULT 'belum_bayar',

    CONSTRAINT uq_invoices_nomor UNIQUE (nomor_tagihan),
    CONSTRAINT uq_invoices_periode
        UNIQUE (rental_id, periode_tagihan),

    CONSTRAINT chk_invoices_total
        CHECK (total_tagihan > 0),

    CONSTRAINT chk_invoices_tanggal
        CHECK (tanggal_jatuh_tempo >= periode_tagihan),

    CONSTRAINT chk_invoices_status
        CHECK (
            status_tagihan IN (
                'belum_bayar',
                'sebagian',
                'lunas',
                'terlambat'
            )
        ),

    CONSTRAINT fk_invoices_rentals
        FOREIGN KEY (rental_id)
        REFERENCES rentals(rental_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =====================================================
-- 14. TABEL PAYMENTS
-- =====================================================

CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_id INT NOT NULL,
    jumlah_bayar DECIMAL(12,2) NOT NULL,
    tanggal_bayar DATE NOT NULL,
    metode_pembayaran VARCHAR(50) NOT NULL,
    status_pembayaran VARCHAR(20) NOT NULL DEFAULT 'menunggu',
    verified_by INT NULL,

    CONSTRAINT chk_payments_jumlah
        CHECK (jumlah_bayar > 0),

    CONSTRAINT chk_payments_status
        CHECK (
            status_pembayaran IN (
                'menunggu',
                'diterima',
                'ditolak'
            )
        ),

    CONSTRAINT fk_payments_invoices
        FOREIGN KEY (invoice_id)
        REFERENCES invoices(invoice_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_payments_verifier
        FOREIGN KEY (verified_by)
        REFERENCES users(user_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB;

-- =====================================================
-- 15. TABEL PAYMENT_PROOFS
-- =====================================================

CREATE TABLE payment_proofs (
    proof_id INT AUTO_INCREMENT PRIMARY KEY,
    payment_id INT NOT NULL,
    nama_file VARCHAR(255) NOT NULL,
    lokasi_file VARCHAR(255) NOT NULL,
    tanggal_upload DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_payment_proofs_payments
        FOREIGN KEY (payment_id)
        REFERENCES payments(payment_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =====================================================
-- 16. TABEL INVENTORY_STOCKS
-- =====================================================

CREATE TABLE inventory_stocks (
    stock_id INT AUTO_INCREMENT PRIMARY KEY,
    property_id INT NOT NULL,
    item_id INT NOT NULL,
    room_id INT NULL,
    jumlah INT NOT NULL DEFAULT 0,

    CONSTRAINT chk_inventory_stocks_jumlah
        CHECK (jumlah >= 0),

    CONSTRAINT fk_inventory_stocks_properties
        FOREIGN KEY (property_id)
        REFERENCES properties(property_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_inventory_stocks_items
        FOREIGN KEY (item_id)
        REFERENCES inventory_items(item_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_inventory_stocks_rooms
        FOREIGN KEY (room_id)
        REFERENCES rooms(room_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =====================================================
-- 17. TABEL COMPLAINTS
-- =====================================================

CREATE TABLE complaints (
    complaint_id INT AUTO_INCREMENT PRIMARY KEY,
    rental_id INT NOT NULL,
    judul_keluhan VARCHAR(150) NOT NULL,
    deskripsi_keluhan TEXT NOT NULL,
    tanggal_keluhan DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status_keluhan VARCHAR(20) NOT NULL DEFAULT 'diajukan',

    CONSTRAINT chk_complaints_status
        CHECK (
            status_keluhan IN (
                'diajukan',
                'diproses',
                'selesai',
                'ditolak'
            )
        ),

    CONSTRAINT fk_complaints_rentals
        FOREIGN KEY (rental_id)
        REFERENCES rentals(rental_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =====================================================
-- 18. TABEL MAINTENANCE_TASKS
-- =====================================================

CREATE TABLE maintenance_tasks (
    task_id INT AUTO_INCREMENT PRIMARY KEY,
    complaint_id INT NOT NULL,
    employee_id INT NOT NULL,
    deskripsi_tugas TEXT NOT NULL,
    tanggal_tugas DATE NOT NULL,
    status_tugas VARCHAR(20) NOT NULL DEFAULT 'ditugaskan',

    CONSTRAINT chk_maintenance_status
        CHECK (
            status_tugas IN (
                'ditugaskan',
                'dikerjakan',
                'selesai'
            )
        ),

    CONSTRAINT fk_maintenance_complaints
        FOREIGN KEY (complaint_id)
        REFERENCES complaints(complaint_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_maintenance_employees
        FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =====================================================
-- SELESAI: 18 TABEL DATABASE KOSKITA
-- =====================================================
