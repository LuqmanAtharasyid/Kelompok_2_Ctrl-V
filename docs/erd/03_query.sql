USE koskita;

-- Pertanyaan bisnis: Menampilkan daftar sewa aktif beserta nama penghuni, nomor kamar, nama properti, dan tanggal mulai sewa.
-- Halaman atau fitur: Halaman Daftar Sewa Aktif / Dashboard Pengelola.
-- Jumlah baris: 6
SELECT u.nama AS nama_penghuni,
       rm.nomor_kamar,
       p.nama_properti,
       rt.tanggal_mulai
FROM rentals rt
JOIN tenants t ON rt.tenant_id = t.tenant_id
JOIN users u ON t.user_id = u.user_id
JOIN rooms rm ON rt.room_id = rm.room_id
JOIN properties p ON rm.property_id = p.property_id
WHERE rt.status_sewa = 'aktif';

-- Pertanyaan bisnis: Kamar mana saja yang belum pernah memiliki riwayat sewa sama sekali?
-- Halaman atau fitur: Halaman Katalog Kamar Tersedia / Belum Tersewa.
-- Jumlah baris: 1
SELECT rm.nomor_kamar,
       rm.harga_sewa,
       rm.status_kamar
FROM rooms rm
LEFT JOIN rentals rt ON rm.room_id = rt.room_id
WHERE rt.rental_id IS NULL;

-- Pertanyaan bisnis: Properti mana saja yang memiliki lebih dari 1 tagihan (invoice) tercatat?
-- Halaman atau fitur: Laporan Tagihan per Properti.
-- Jumlah baris: 1
SELECT p.nama_properti,
       COUNT(inv.invoice_id) AS jumlah_tagihan,
       SUM(inv.total_tagihan) AS total_nominal_tagihan
FROM properties p
JOIN rooms rm ON p.property_id = rm.property_id
JOIN rentals rt ON rm.room_id = rt.room_id
JOIN invoices inv ON rt.rental_id = inv.rental_id
GROUP BY p.property_id, p.nama_properti
HAVING COUNT(inv.invoice_id) > 1;

-- Pertanyaan bisnis: Kamar mana saja yang harga sewanya di atas rata-rata harga sewa seluruh kamar?
-- Halaman atau fitur: Filter & Rekomendasi Kamar di Atas Rata-Rata Harga.
-- Jumlah baris: 3
SELECT nomor_kamar,
       harga_sewa,
       status_kamar
FROM rooms
WHERE harga_sewa > (
    SELECT AVG(harga_sewa)
    FROM rooms
);

-- Pertanyaan bisnis: Bagaimana riwayat pembayaran dan status verifikasinya per penghuni (uji jalur ERD P19)?
-- Halaman atau fitur: Riwayat Pembayaran Penghuni.
-- Jumlah baris: 13
SELECT u.nama AS nama_penghuni,
       inv.nomor_tagihan,
       pay.jumlah_bayar,
       pay.tanggal_bayar,
       pay.status_pembayaran
FROM payments pay
JOIN invoices inv ON pay.invoice_id = inv.invoice_id
JOIN rentals rt ON inv.rental_id = rt.rental_id
JOIN tenants t ON rt.tenant_id = t.tenant_id
JOIN users u ON t.user_id = u.user_id
ORDER BY pay.tanggal_bayar DESC;

-- Pertanyaan bisnis: Keluhan apa saja yang masih berstatus diajukan atau diproses beserta nomor kamar dan nama penghuni?
-- Halaman atau fitur: Daftar Keluhan Aktif Penghuni.
-- Jumlah baris: 2
SELECT c.judul,
       c.status_keluhan,
       rm.nomor_kamar,
       u.nama AS nama_penghuni
FROM complaints c
JOIN rentals rt ON c.rental_id = rt.rental_id
JOIN rooms rm ON rt.room_id = rm.room_id
JOIN tenants t ON rt.tenant_id = t.tenant_id
JOIN users u ON t.user_id = u.user_id
WHERE c.status_keluhan IN ('diajukan', 'diproses');