# This file contains all the record creation needed to seed the database with its default values.
# The data can be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Destroy existing records to ensure a clean slate
Rails.logger.info "Destroying all existing records..."
[RekeningBank, BantuanDanaBeasiswa, Donasi, PenggalanganDanaBeasiswa,
 PenanggungJawabNonBeasiswaHasPenerimaNonBeasiswa, DokumenSertifikat,
 CivitasAkademika, Donatur, Mahasiswa, PenanggungJawab,
 PenerimaNonBeasiswa, BantuanDanaNonBeasiswa, PenanggungJawabNonBeasiswa].each(&:destroy_all)

# Reset auto-increment counters only for tables with single-column integer primary keys
ActiveRecord::Base.connection.execute("ALTER TABLE bantuandanabeasiswa AUTO_INCREMENT = 1")
ActiveRecord::Base.connection.execute("ALTER TABLE bantuandananonbeasiswa AUTO_INCREMENT = 1")
ActiveRecord::Base.connection.execute("ALTER TABLE penggalangandanabeasiswa AUTO_INCREMENT = 1")
ActiveRecord::Base.connection.execute("ALTER TABLE donasi AUTO_INCREMENT = 1")
ActiveRecord::Base.connection.execute("ALTER TABLE rekeningbank AUTO_INCREMENT = 1")

# Seeder untuk CivitasAkademika
Rails.logger.info "Seeding CivitasAkademika..."
CivitasAkademika.create!([
  { nomor_induk: "231511038", nama: "Daffa Al Ghifari" },
  { nomor_induk: "231511039", nama: "Daiva Raditya Pradipa" },
  { nomor_induk: "231511040", nama: "Dhea Dria Spralia" },
  { nomor_induk: "231511041", nama: "Dhira Ramadini" },
  { nomor_induk: "231511042", nama: "Bagyo Sutoyo" },
  { nomor_induk: "231511055", nama: "Muhammad Raihan Pratama" },
])

# Seeder untuk Donatur
Rails.logger.info "Seeding Donatur..."
Donatur.create!([
  { nomor_telepon: "081234567890", nama: "Donatur A", password: "password123", status: 1 },
  { nomor_telepon: "082345678901", nama: "Donatur B", password: "password123", status: 0 },
  { nomor_telepon: "083456789012", nama: "Donatur C", password: "password123", status: 1 },
  { nomor_telepon: "084567890123", nama: "Donatur D", password: "password123", status: 0 },
  { nomor_telepon: "085678901234", nama: "Donatur E", password: "password123", status: 1 }
])

# Seeder untuk Mahasiswa
Rails.logger.info "Seeding Mahasiswa..."
Mahasiswa.create!([
  { nim: "231511038", nama: "Daffa Al Ghifari", nomor_telepon: "089876543210" },
  { nim: "231511039", nama: "Daiva Raditya Pradipa", nomor_telepon: "088765432109" },
  { nim: "231511040", nama: "Dhea Dria Spralia", nomor_telepon: "089876545555" },
  { nim: "231511041", nama: "Dhira Ramadini", nomor_telepon: "081998877664" },
  { nim: "231511055", nama: "Muhammad Raihan Pratama", nomor_telepon: "081281126668" }
])

# Seeder untuk PenanggungJawab (use unique role as primary key, starting from 0)
Rails.logger.info "Seeding PenanggungJawab..."
penanggung_jawab_records = PenanggungJawab.create!([
  { role: 0, nama: "Admin Beasiswa", username: "admin_b", password: "password123", nomor_telepon: "081122334455" },
  { role: 1, nama: "Admin Non Beasiswa", username: "admin_nb", password: "password123", nomor_telepon: "082233445566" },
  { role: 2, nama: "Admin Beasiswa 2", username: "admin_b2", password: "password123", nomor_telepon: "081133445577" },
  { role: 3, nama: "Admin Non Beasiswa 2", username: "admin_nb2", password: "password123", nomor_telepon: "082244556688" },
  { role: 4, nama: "Admin Beasiswa 3", username: "admin_b3", password: "password123", nomor_telepon: "081155667799" }
])

# Map PenanggungJawab role values for use in dependent tables
penanggung_jawab_roles = penanggung_jawab_records.map(&:role)
Rails.logger.info "PenanggungJawab roles created: #{penanggung_jawab_roles}"

# Seeder untuk PenanggungJawabNonBeasiswa
Rails.logger.info "Seeding PenanggungJawabNonBeasiswa..."
PenanggungJawabNonBeasiswa.create!([
  { nomor_induk: "231511041", nama: "Dhira Ramadini", nomor_telepon: "081998877664" },
  { nomor_induk: "231511042", nama: "Bagyo Sutoyo", nomor_telepon: "082287654321" },
  { nomor_induk: "231511055", nama: "Muhammad Raihan Pratama", nomor_telepon: "081281126668" }
])

# Seeder untuk PenerimaNonBeasiswa
Rails.logger.info "Seeding PenerimaNonBeasiswa..."
PenerimaNonBeasiswa.create!([
  { nomor_induk: "231511038", nama: "Daffa Al Ghifari", nomor_telepon: "089876543210" },
  { nomor_induk: "231511039", nama: "Daiva Raditya Pradipa", nomor_telepon: "088765432109" },
  { nomor_induk: "231511040", nama: "Dhea Dria Spralia", nomor_telepon: "089876545555" },
  { nomor_induk: "231511041", nama: "Dhira Ramadini", nomor_telepon: "081998877664" },
  { nomor_induk: "231511055", nama: "Muhammad Raihan Pratama", nomor_telepon: "081281126668" }
])

# Seeder untuk PenggalanganDanaBeasiswa (5 entries, composite primary key)
Rails.logger.info "Seeding PenggalanganDanaBeasiswa..."
penggalangan_dana_records = PenggalanganDanaBeasiswa.create!([
  {
    penggalangan_dana_beasiswa_id: 1,
    penanggung_jawab_id: penanggung_jawab_roles[0], # Now references role 0
    deskripsi: "Bantuan dana UKT untuk mahasiswa terdampak ekonomi",
    judul: "Beasiswa Peduli Pendidikan 2025",
    waktu_dimulai: Date.new(2025, 5, 1),
    waktu_berakhir: Date.new(2025, 8, 31),
    kuota_beasiswa: 100,
    target_dana: 200_000_000,
    target_penerima: 100,
    total_nominal_terkumpul: 75_000_000,
    status: 0
  },
  {
    penggalangan_dana_beasiswa_id: 2,
    penanggung_jawab_id: penanggung_jawab_roles[2], # Now references role 2
    deskripsi: "Bantuan dana untuk mahasiswa berprestasi",
    judul: "Beasiswa Prestasi Akademik 2025",
    waktu_dimulai: Date.new(2025, 6, 1),
    waktu_berakhir: Date.new(2025, 9, 30),
    kuota_beasiswa: 50,
    target_dana: 150_000_000,
    target_penerima: 50,
    total_nominal_terkumpul: 50_000_000,
    status: 0
  },
  {
    penggalangan_dana_beasiswa_id: 3,
    penanggung_jawab_id: penanggung_jawab_roles[4], # Now references role 4
    deskripsi: "Bantuan dana untuk mahasiswa kurang mampu",
    judul: "Beasiswa Solidaritas 2025",
    waktu_dimulai: Date.new(2025, 7, 1),
    waktu_berakhir: Date.new(2025, 10, 31),
    kuota_beasiswa: 80,
    target_dana: 180_000_000,
    target_penerima: 80,
    total_nominal_terkumpul: 60_000_000,
    status: 0
  },
  {
    penggalangan_dana_beasiswa_id: 4,
    penanggung_jawab_id: penanggung_jawab_roles[0], # Now references role 0
    deskripsi: "Bantuan dana untuk mahasiswa terdampak bencana",
    judul: "Beasiswa Darurat Bencana 2025",
    waktu_dimulai: Date.new(2025, 5, 15),
    waktu_berakhir: Date.new(2025, 8, 15),
    kuota_beasiswa: 30,
    target_dana: 100_000_000,
    target_penerima: 30,
    total_nominal_terkumpul: 25_000_000,
    status: 0
  },
  {
    penggalangan_dana_beasiswa_id: 5,
    penanggung_jawab_id: penanggung_jawab_roles[2], # Now references role 2
    deskripsi: "Bantuan dana untuk penelitian mahasiswa",
    judul: "Beasiswa Penelitian 2025",
    waktu_dimulai: Date.new(2025, 8, 1),
    waktu_berakhir: Date.new(2025, 11, 30),
    kuota_beasiswa: 20,
    target_dana: 80_000_000,
    target_penerima: 20,
    total_nominal_terkumpul: 15_000_000,
    status: 0
  }
])

# Map PenggalanganDanaBeasiswa IDs
penggalangan_dana_ids = penggalangan_dana_records.map(&:penggalangan_dana_beasiswa_id)
Rails.logger.info "PenggalanganDanaBeasiswa IDs created: #{penggalangan_dana_ids}"

# Seeder untuk BantuanDanaBeasiswa (5 entries, composite primary key)
Rails.logger.info "Seeding BantuanDanaBeasiswa..."
BantuanDanaBeasiswa.create!([
  {
    bantuan_dana_beasiswa_id: 1,
    mahasiswa_id: "231511038",
    penggalangan_dana_beasiswa_id: penggalangan_dana_ids[0],
    alasan_butuh_bantuan: "Kesulitan finansial karena orang tua terkena PHK",
    golongan_ukt: 3,
    kuitansi_pembayaran_ukt: "kuitansi_ukt_231511038.pdf",
    gaji_orang_tua: 2500000,
    bukti_slip_gaji_orang_tua: "slip_gaji_ayah_231511038.pdf",
    esai: "Saya sangat membutuhkan bantuan ini untuk melanjutkan kuliah.",
    jumlah_tanggungan_keluarga: 4,
    biaya_transportasi: "500000",
    biaya_internet: "300000",
    biaya_kos: "700000",
    biaya_konsumsi: "1000000",
    total_pengeluaran_keluarga: 4500000,
    penilaian_esai: 85,
    nominal_penyaluran: [0, 0],
    dokumen_kehadiran_perkuliahan: "kehadiran_231511038.pdf",
    status_pengajuan: 1,
    status_penyaluran: [0, 0],
    status_kehadiran_perkuliahan: 1
  },
  {
    bantuan_dana_beasiswa_id: 2,
    mahasiswa_id: "231511039",
    penggalangan_dana_beasiswa_id: penggalangan_dana_ids[1],
    alasan_butuh_bantuan: "Membutuhkan dana untuk biaya penelitian",
    golongan_ukt: 2,
    kuitansi_pembayaran_ukt: "kuitansi_ukt_231511039.pdf",
    gaji_orang_tua: 3000000,
    bukti_slip_gaji_orang_tua: "slip_gaji_ayah_231511039.pdf",
    esai: "Bantuan ini akan membantu saya menyelesaikan proyek penelitian.",
    jumlah_tanggungan_keluarga: 3,
    biaya_transportasi: "400000",
    biaya_internet: "250000",
    biaya_kos: "600000",
    biaya_konsumsi: "900000",
    total_pengeluaran_keluarga: 4000000,
    penilaian_esai: 90,
    nominal_penyaluran: [0, 0],
    dokumen_kehadiran_perkuliahan: "kehadiran_231511039.pdf",
    status_pengajuan: 1,
    status_penyaluran: [0, 0],
    status_kehadiran_perkuliahan: 1
  },
  {
    bantuan_dana_beasiswa_id: 3,
    mahasiswa_id: "231511040",
    penggalangan_dana_beasiswa_id: penggalangan_dana_ids[2],
    alasan_butuh_bantuan: "Kesulitan membayar UKT karena penurunan pendapatan keluarga",
    golongan_ukt: 4,
    kuitansi_pembayaran_ukt: "kuitansi_ukt_231511040.pdf",
    gaji_orang_tua: 2000000,
    bukti_slip_gaji_orang_tua: "slip_gaji_ayah_231511040.pdf",
    esai: "Beasiswa ini akan membantu saya fokus pada studi.",
    jumlah_tanggungan_keluarga: 5,
    biaya_transportasi: "600000",
    biaya_internet: "350000",
    biaya_kos: "800000",
    biaya_konsumsi: "1200000",
    total_pengeluaran_keluarga: 5000000,
    penilaian_esai: 80,
    nominal_penyaluran: [0, 0],
    dokumen_kehadiran_perkuliahan: "kehadiran_231511040.pdf",
    status_pengajuan: 1,
    status_penyaluran: [0, 0],
    status_kehadiran_perkuliahan: 1
  },
  {
    bantuan_dana_beasiswa_id: 4,
    mahasiswa_id: "231511041",
    penggalangan_dana_beasiswa_id: penggalangan_dana_ids[3],
    alasan_butuh_bantuan: "Keluarga terdampak banjir, membutuhkan bantuan darurat",
    golongan_ukt: 3,
    kuitansi_pembayaran_ukt: "kuitansi_ukt_231511041.pdf",
    gaji_orang_tua: 2700000,
    bukti_slip_gaji_orang_tua: "slip_gaji_ayah_231511041.pdf",
    esai: "Bantuan ini akan meringankan beban keluarga pasca bencana.",
    jumlah_tanggungan_keluarga: 4,
    biaya_transportasi: "550000",
    biaya_internet: "300000",
    biaya_kos: "750000",
    biaya_konsumsi: "1100000",
    total_pengeluaran_keluarga: 4700000,
    penilaian_esai: 88,
    nominal_penyaluran: [0, 0],
    dokumen_kehadiran_perkuliahan: "kehadiran_231511041.pdf",
    status_pengajuan: 1,
    status_penyaluran: [0, 0],
    status_kehadiran_perkuliahan: 1
  },
  {
    bantuan_dana_beasiswa_id: 5,
    mahasiswa_id: "231511055",
    penggalangan_dana_beasiswa_id: penggalangan_dana_ids[4],
    alasan_butuh_bantuan: "Membutuhkan dana untuk seminar internasional",
    golongan_ukt: 2,
    kuitansi_pembayaran_ukt: "kuitansi_ukt_231511055.pdf",
    gaji_orang_tua: 3500000,
    bukti_slip_gaji_orang_tua: "slip_gaji_ayah_231511055.pdf",
    esai: "Bantuan ini akan mendukung partisipasi saya di seminar internasional.",
    jumlah_tanggungan_keluarga: 3,
    biaya_transportasi: "450000",
    biaya_internet: "200000",
    biaya_kos: "650000",
    biaya_konsumsi: "950000",
    total_pengeluaran_keluarga: 4200000,
    penilaian_esai: 92,
    nominal_penyaluran: [0, 0],
    dokumen_kehadiran_perkuliahan: "kehadiran_231511055.pdf",
    status_pengajuan: 1,
    status_penyaluran: [0, 0],
    status_kehadiran_perkuliahan: 1
  }
])

# Seeder untuk BantuanDanaNonBeasiswa (5 entries, composite primary key)
Rails.logger.info "Seeding BantuanDanaNonBeasiswa..."
bantuan_dana_non_beasiswa_records = BantuanDanaNonBeasiswa.create!([
  {
    bantuan_dana_non_beasiswa_id: 1,
    penanggung_jawab_non_beasiswa_id: "231511042",
    judul_galang_dana: "Bantuan Darurat untuk Mahasiswa",
    waktu_galang_dana: Date.new(2025, 5, 10),
    deskripsi_galang_dana: "Dana ini akan digunakan untuk membantu mahasiswa dalam kondisi darurat.",
    dana_yang_dibutuhkan: 10000000,
    bukti_butuh_bantuan: "bukti_darurat_1.pdf",
    kategori: "Bencana",
    total_nominal_terkumpul: 3000000,
    status_pengajuan: 1,
    status_penyaluran: 0
  },
  {
    bantuan_dana_non_beasiswa_id: 2,
    penanggung_jawab_non_beasiswa_id: "231511041",
    judul_galang_dana: "Bantuan Medis Mahasiswa",
    waktu_galang_dana: Date.new(2025, 6, 1),
    deskripsi_galang_dana: "Dana untuk membantu biaya pengobatan mahasiswa.",
    dana_yang_dibutuhkan: 15000000,
    bukti_butuh_bantuan: "bukti_medis_2.pdf",
    kategori: "Medis",
    total_nominal_terkumpul: 5000000,
    status_pengajuan: 1,
    status_penyaluran: 0
  },
  {
    bantuan_dana_non_beasiswa_id: 3,
    penanggung_jawab_non_beasiswa_id: "231511055",
    judul_galang_dana: "Bantuan Duka Mahasiswa",
    waktu_galang_dana: Date.new(2025, 7, 1),
    deskripsi_galang_dana: "Dana untuk membantu mahasiswa yang kehilangan anggota keluarga.",
    dana_yang_dibutuhkan: 8000000,
    bukti_butuh_bantuan: "bukti_duka_3.pdf",
    kategori: "Duka",
    total_nominal_terkumpul: 2000000,
    status_pengajuan: 1,
    status_penyaluran: 0
  },
  {
    bantuan_dana_non_beasiswa_id: 4,
    penanggung_jawab_non_beasiswa_id: "231511042",
    judul_galang_dana: "Bantuan Bencana Mahasiswa",
    waktu_galang_dana: Date.new(2025, 8, 1),
    deskripsi_galang_dana: "Dana untuk membantu mahasiswa terdampak bencana alam.",
    dana_yang_dibutuhkan: 12000000,
    bukti_butuh_bantuan: "bukti_bencana_4.pdf",
    kategori: "Bencana",
    total_nominal_terkumpul: 4000000,
    status_pengajuan: 1,
    status_penyaluran: 0
  },
  {
    bantuan_dana_non_beasiswa_id: 5,
    penanggung_jawab_non_beasiswa_id: "231511041",
    judul_galang_dana: "Bantuan Medis Darurat",
    waktu_galang_dana: Date.new(2025, 9, 1),
    deskripsi_galang_dana: "Dana untuk membantu biaya medis darurat mahasiswa.",
    dana_yang_dibutuhkan: 20000000,
    bukti_butuh_bantuan: "bukti_medis_5.pdf",
    kategori: "Medis",
    total_nominal_terkumpul: 6000000,
    status_pengajuan: 1,
    status_penyaluran: 0
  }
])

# Map BantuanDanaNonBeasiswa IDs
bantuan_dana_non_beasiswa_ids = bantuan_dana_non_beasiswa_records.map(&:bantuan_dana_non_beasiswa_id)
Rails.logger.info "BantuanDanaNonBeasiswa IDs created: #{bantuan_dana_non_beasiswa_ids}"

# Seeder untuk DokumenSertifikat (5 entries, composite primary key)
Rails.logger.info "Seeding DokumenSertifikat..."
dokumen_sertifikat_records = DokumenSertifikat.create!([
  { jenis: 1, donatur_id: "081234567890" },
  { jenis: 2, donatur_id: "082345678901" },
  { jenis: 3, donatur_id: "083456789012" },
  { jenis: 4, donatur_id: "084567890123" },
  { jenis: 5, donatur_id: "085678901234" }
])

# Map DokumenSertifikat jenis values (part of composite primary key)
dokumen_sertifikat_jenis = dokumen_sertifikat_records.map(&:jenis)
Rails.logger.info "DokumenSertifikat jenis created: #{dokumen_sertifikat_jenis}"

# Seeder untuk Donasi (5 entries, composite primary key)
Rails.logger.info "Seeding Donasi..."
Donasi.create!([
  {
    nomor_referensi: "REF123456",
    donatur_id: "081234567890",
    nominal_donasi: 500000,
    struk_pembayaran: "struk_pembayaran_1.pdf",
    waktu_berakhir: Time.now + 1.month,
    tanggal_approve: Date.today,
    status: 1,
    bantuan_dana_non_beasiswa_id: bantuan_dana_non_beasiswa_ids[0],
    penggalangan_dana_beasiswa_id: penggalangan_dana_ids[0],
    dokumen_sertifikat_id: dokumen_sertifikat_jenis[0]
  },
  {
    nomor_referensi: "REF123457",
    donatur_id: "082345678901",
    nominal_donasi: 750000,
    struk_pembayaran: "struk_pembayaran_2.pdf",
    waktu_berakhir: Time.now + 1.month,
    tanggal_approve: Date.today,
    status: 1,
    bantuan_dana_non_beasiswa_id: bantuan_dana_non_beasiswa_ids[1],
    penggalangan_dana_beasiswa_id: penggalangan_dana_ids[1],
    dokumen_sertifikat_id: dokumen_sertifikat_jenis[1]
  },
  {
    nomor_referensi: "REF123458",
    donatur_id: "083456789012",
    nominal_donasi: 1000000,
    struk_pembayaran: "struk_pembayaran_3.pdf",
    waktu_berakhir: Time.now + 1.month,
    tanggal_approve: Date.today,
    status: 1,
    bantuan_dana_non_beasiswa_id: bantuan_dana_non_beasiswa_ids[2],
    penggalangan_dana_beasiswa_id: penggalangan_dana_ids[2],
    dokumen_sertifikat_id: dokumen_sertifikat_jenis[2]
  },
  {
    nomor_referensi: "REF123459",
    donatur_id: "084567890123",
    nominal_donasi: 600000,
    struk_pembayaran: "struk_pembayaran_4.pdf",
    waktu_berakhir: Time.now + 1.month,
    tanggal_approve: Date.today,
    status: 1,
    bantuan_dana_non_beasiswa_id: bantuan_dana_non_beasiswa_ids[3],
    penggalangan_dana_beasiswa_id: penggalangan_dana_ids[3],
    dokumen_sertifikat_id: dokumen_sertifikat_jenis[3]
  },
  {
    nomor_referensi: "REF123460",
    donatur_id: "085678901234",
    nominal_donasi: 800000,
    struk_pembayaran: "struk_pembayaran_5.pdf",
    waktu_berakhir: Time.now + 1.month,
    tanggal_approve: Date.today,
    status: 1,
    bantuan_dana_non_beasiswa_id: bantuan_dana_non_beasiswa_ids[4],
    penggalangan_dana_beasiswa_id: penggalangan_dana_ids[4],
    dokumen_sertifikat_id: dokumen_sertifikat_jenis[4]
  }
])

# Seeder untuk PenanggungJawabNonBeasiswaHasPenerimaNonBeasiswa (5 entries, composite primary key)
Rails.logger.info "Seeding PenanggungJawabNonBeasiswaHasPenerimaNonBeasiswa..."
PenanggungJawabNonBeasiswaHasPenerimaNonBeasiswa.create!([
  { penanggung_jawab_non_beasiswa_id: "231511042", penerima_non_beasiswa_id: "231511038" },
  { penanggung_jawab_non_beasiswa_id: "231511041", penerima_non_beasiswa_id: "231511039" },
  { penanggung_jawab_non_beasiswa_id: "231511055", penerima_non_beasiswa_id: "231511040" },
  { penanggung_jawab_non_beasiswa_id: "231511042", penerima_non_beasiswa_id: "231511041" },
  { penanggung_jawab_non_beasiswa_id: "231511041", penerima_non_beasiswa_id: "231511055" }
])

# Seeder untuk RekeningBank (5 entries)
Rails.logger.info "Seeding RekeningBank..."
RekeningBank.create!([
  {
    nomor_rekening: "1234567890123456",
    nama_bank: "BRI",
    nama_pemilik_rekening: "Daffa Al Ghifari",
    penanggung_jawab_id: penanggung_jawab_roles[0], # Now references role 0
    mahasiswa_id: "231511038",
    penerima_non_beasiswa_id: "231511038",
    donatur_id: "081234567890"
  },
  {
    nomor_rekening: "1234567890123457",
    nama_bank: "BNI",
    nama_pemilik_rekening: "Daiva Raditya Pradipa",
    penanggung_jawab_id: penanggung_jawab_roles[2], # Now references role 2
    mahasiswa_id: "231511039",
    penerima_non_beasiswa_id: "231511039",
    donatur_id: "082345678901"
  },
  {
    nomor_rekening: "1234567890123458",
    nama_bank: "Mandiri",
    nama_pemilik_rekening: "Dhea Dria Spralia",
    penanggung_jawab_id: penanggung_jawab_roles[4], # Now references role 4
    mahasiswa_id: "231511040",
    penerima_non_beasiswa_id: "231511040",
    donatur_id: "083456789012"
  },
  {
    nomor_rekening: "1234567890123459",
    nama_bank: "BCA",
    nama_pemilik_rekening: "Dhira Ramadini",
    penanggung_jawab_id: penanggung_jawab_roles[0], # Now references role 0
    mahasiswa_id: "231511041",
    penerima_non_beasiswa_id: "231511041",
    donatur_id: "084567890123"
  },
  {
    nomor_rekening: "1234567890123460",
    nama_bank: "BRI",
    nama_pemilik_rekening: "Muhammad Raihan Pratama",
    penanggung_jawab_id: penanggung_jawab_roles[2], # Now references role 2
    mahasiswa_id: "231511055",
    penerima_non_beasiswa_id: "231511055",
    donatur_id: "085678901234"
  }
])

Rails.logger.info "Seeding completed successfully!"