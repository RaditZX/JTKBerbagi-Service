# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

RekeningBank.destroy_all
BantuanDanaBeasiswa.destroy_all
Donasi.destroy_all
PenggalanganDanaBeasiswa.destroy_all
PenanggungJawabNonBeasiswaHasPenerimaNonBeasiswa.destroy_all
DokumenSertifikat.destroy_all

CivitasAkademika.destroy_all
Donatur.destroy_all
Mahasiswa.destroy_all
PenanggungJawab.destroy_all
PenerimaNonBeasiswa.destroy_all
BantuanDanaNonBeasiswa.destroy_all
PenanggungJawabNonBeasiswa.destroy_all

CivitasAkademika.create!([
  { nomor_induk: "MHS001", nama: "Agus Santoso" },
  { nomor_induk: "MHS002", nama: "Siti Aminah" },
  { nomor_induk: "MHS003", nama: "Rudy Tabootie"},
  { nomor_induk: "DSN001", nama: "Rina Marlina" },
  { nomor_induk: "DSN002", nama: "Bagyo Sutoyo" },
])

# Seeder untuk Donatur
Donatur.create!([
  { nomor_telepon: "081234567890", nama: "Donatur A", password: "password123", status: 1 },
  { nomor_telepon: "082345678901", nama: "Donatur B", password: "password123", status: 0 }
])

# Seeder untuk Mahasiswa
Mahasiswa.create!([
  { nim: "MHS001", nama: "Agus Santoso", nomor_telepon: "089876543210" },
  { nim: "MHS002", nama: "Siti Aminah", nomor_telepon: "088765432109" },
  { nim: "MHS003", nama: "Rudy Tabootie", nomor_telepon: "089876545555" },
])

# Seeder untuk Penanggung Jawab
PenanggungJawab.create!([
  { role: 1, nama: "Admin Beasiswa", username: "admin_b", password: "password123", nomor_telepon: "081122334455" },
  { role: 2, nama: "Admin Non Beasiswa", username: "admin_nb", password: "password123", nomor_telepon: "082233445566" }
])

# Seeder untuk Penanggung Jawab Non Beasiswa
PenanggungJawabNonBeasiswa.create!([
  { nomor_induk: "DSN001", nama: "Rina Marlina", nomor_telepon: "081998877665" },
  { nomor_induk: "DSN002", nama: "Bagyo Sutoyo", nomor_telepon: "082287654321" }
])

# Seeder untuk Penerima Non Beasiswa
PenerimaNonBeasiswa.create!([
  { nomor_induk: "MHS003", nama: "Rudy Tabootie", nomor_telepon: "089876545555" },
  { nomor_induk: "MHS002", nama: "Siti Aminah", nomor_telepon: "088765432109" }
])

PenggalanganDanaBeasiswa.create!(
  penggalangan_dana_beasiswa_id: 1,
  penanggung_jawab_id: 1,
  deskripsi: "Bantuan dana UKT untuk mahasiswa terdampak ekonomi",
  judul: "Beasiswa Peduli Pendidikan 2025",
  waktu_dimulai: Date.new(2025, 5, 1),
  waktu_berakhir: Date.new(2025, 8, 31),
  kuota_beasiswa: 100,
  target_dana: 200_000_000,
  target_penerima: 100,
  total_nominal_terkumpul: 75_000_000,
  status: 1
)

BantuanDanaBeasiswa.create!(
  bantuan_dana_beasiswa_id: 1,
  mahasiswa_id: "MHS001",
  penggalangan_dana_beasiswa_id: 1,
  alasan_butuh_bantuan: "Kesulitan finansial karena orang tua terkena PHK",
  golongan_ukt: 3,
  kuitansi_pembayaran_ukt: "kuitansi_ukt_mhs001.pdf",
  gaji_orang_tua: 2500000,
  bukti_slip_gaji_orang_tua: "slip_gaji_ayah_mhs001.pdf",
  esai: "Saya sangat membutuhkan bantuan ini untuk melanjutkan kuliah.",
  jumlah_tanggungan_keluarga: 4,
  biaya_transportasi: "500000",
  biaya_internet: "300000",
  biaya_kos: "700000",
  biaya_konsumsi: "1000000",
  total_pengeluaran_keluarga: 4500000,
  penilaian_esai: 85,
  nominal_penyaluran: { tahap_1: 1000000, tahap_2: 1000000 },
  dokumen_kehadiran_perkuliahan: "kehadiran_mhs001.pdf",
  status_pengajuan: 1,
  status_penyaluran: { tahap_1: "disalurkan", tahap_2: "belum" },
  status_kehadiran_perkuliahan: 1
)

BantuanDanaNonBeasiswa.create!(
  bantuan_dana_non_beasiswa_id: 1,
  penanggung_jawab_non_beasiswa_id: "DSN002",
  judul_galang_dana: "Bantuan Darurat untuk Mahasiswa",
  waktu_galang_dana: Date.new(2025, 5, 10),
  deskripsi_galang_dana: "Dana ini akan digunakan untuk membantu mahasiswa dalam kondisi darurat.",
  dana_yang_dibutuhkan: 10000000,
  bukti_butuh_bantuan: "bukti_darurat.pdf",
  kategori: "Bencana",
  total_nominal_terkumpul: 3000000,
  status_pengajuan: 1,
  status_penyaluran: 0
)

DokumenSertifikat.create!(
  jenis: 1,
  donatur_id: "081234567890"
)

# Membuat donasi
Donasi.create!(
  nomor_referensi: "REF123456",
  nominal_donasi: 500000,
  struk_pembayaran: "struk_pembayaran_url",
  waktu_berakhir: Time.now + 1.month,
  tanggal_approve: Date.today,
  status: 1,
  bantuan_dana_non_beasiswa_id: 1,
  penggalangan_dana_beasiswa_id: 1,
  donatur_id: "081234567890",
  dokumen_sertifikat_id: 1
)

PenanggungJawabNonBeasiswaHasPenerimaNonBeasiswa.create!(
  penanggung_jawab_non_beasiswa_id: "DSN002",
  penerima_non_beasiswa_id: "MHS002"
)

RekeningBank.create!(
  nomor_rekening: "1234567890123456",
  nama_bank: "BRI",
  nama_pemilik_rekening: "Bagyo Sutoyo",
  penanggung_jawab_id: 1,
  mahasiswa_id: "MHS002",
  penerima_non_beasiswa_id: "MHS002",
  donatur_id: "081234567890"
)