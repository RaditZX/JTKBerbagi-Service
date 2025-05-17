# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2023_11_01_160721) do

  create_table "bantuandanabeasiswa", primary_key: ["bantuan_dana_beasiswa_id", "mahasiswa_id", "penggalangan_dana_beasiswa_id"], charset: "utf8mb3", force: :cascade do |t|
    t.integer "bantuan_dana_beasiswa_id", null: false
    t.string "alasan_butuh_bantuan", limit: 500, null: false
    t.integer "golongan_ukt", null: false
    t.string "kuitansi_pembayaran_ukt", limit: 500, null: false
    t.integer "gaji_orang_tua", null: false
    t.string "bukti_slip_gaji_orang_tua", limit: 500, null: false
    t.string "esai", limit: 500, null: false
    t.integer "jumlah_tanggungan_keluarga", null: false
    t.string "biaya_transportasi", limit: 500, null: false
    t.string "biaya_internet", limit: 500, null: false
    t.string "biaya_kos", limit: 500
    t.string "biaya_konsumsi", limit: 500, null: false
    t.integer "total_pengeluaran_keluarga", null: false
    t.integer "penilaian_esai"
    t.json "nominal_penyaluran"
    t.string "dokumen_kehadiran_perkuliahan", limit: 500
    t.integer "status_pengajuan", null: false
    t.json "status_penyaluran"
    t.integer "status_kehadiran_perkuliahan"
    t.string "mahasiswa_id", limit: 500, null: false
    t.integer "penggalangan_dana_beasiswa_id", null: false
    t.index ["bantuan_dana_beasiswa_id"], name: "bantuan_dana_beasiswa_id_UNIQUE", unique: true
    t.index ["mahasiswa_id"], name: "fk_BantuanDanaBeasiswa_Mahasiswa1_idx"
    t.index ["penggalangan_dana_beasiswa_id"], name: "fk_BantuanDanaBeasiswa_PenggalanganDanaBeasiswa1_idx"
  end

  create_table "bantuandananonbeasiswa", primary_key: ["bantuan_dana_non_beasiswa_id", "penanggung_jawab_non_beasiswa_id"], charset: "utf8mb3", force: :cascade do |t|
    t.integer "bantuan_dana_non_beasiswa_id", null: false
    t.string "judul_galang_dana", limit: 500, null: false
    t.date "waktu_galang_dana", null: false
    t.string "deskripsi_galang_dana", limit: 500, null: false
    t.integer "dana_yang_dibutuhkan", null: false
    t.string "bukti_butuh_bantuan", limit: 500, null: false
    t.string "kategori", limit: 500, null: false
    t.integer "total_nominal_terkumpul"
    t.integer "status_pengajuan", null: false
    t.integer "status_penyaluran"
    t.string "penanggung_jawab_non_beasiswa_id", limit: 500, null: false
    t.index ["bantuan_dana_non_beasiswa_id"], name: "bantuan_dana_non_beasiswa_id_UNIQUE", unique: true
    t.index ["penanggung_jawab_non_beasiswa_id"], name: "fk_BantuanDanaNonBeasiswa_PenanggungJawabNonBeasiswa1_idx"
  end

  create_table "civitasakademika", primary_key: "nomor_induk", id: { type: :string, limit: 500 }, charset: "utf8mb3", force: :cascade do |t|
    t.string "nama", limit: 500, null: false
    t.index ["nomor_induk"], name: "nomor_induk_UNIQUE", unique: true
  end

  create_table "dokumensertifikat", primary_key: ["jenis", "donatur_id"], charset: "utf8mb3", force: :cascade do |t|
    t.integer "jenis", null: false
    t.string "donatur_id", limit: 500, null: false
    t.index ["donatur_id"], name: "fk_DokumenSertifikat_Donatur1_idx"
    t.index ["jenis"], name: "jenis_UNIQUE", unique: true
  end

  create_table "donasi", primary_key: ["nomor_referensi", "donatur_id"], charset: "utf8mb3", force: :cascade do |t|
    t.string "nomor_referensi", limit: 500, null: false
    t.integer "nominal_donasi", null: false
    t.string "struk_pembayaran", limit: 500
    t.time "waktu_berakhir", null: false
    t.date "tanggal_approve"
    t.integer "status", null: false
    t.integer "bantuan_dana_non_beasiswa_id"
    t.integer "penggalangan_dana_beasiswa_id"
    t.string "donatur_id", limit: 500, null: false
    t.integer "dokumen_sertifikat_id"
    t.index ["bantuan_dana_non_beasiswa_id"], name: "fk_Donasi_BantuanDanaNonBeasiswa1_idx"
    t.index ["dokumen_sertifikat_id"], name: "fk_Donasi_DokumenSertifikat1_idx"
    t.index ["donatur_id"], name: "fk_Donasi_Donatur1_idx"
    t.index ["nomor_referensi"], name: "nomor_referensi_UNIQUE", unique: true
    t.index ["penggalangan_dana_beasiswa_id"], name: "fk_Donasi_PenggalanganDanaBeasiswa1_idx"
  end

  create_table "donatur", primary_key: "nomor_telepon", id: { type: :string, limit: 500 }, charset: "utf8mb3", force: :cascade do |t|
    t.string "nama", limit: 500, null: false
    t.string "password_digest", limit: 500
    t.integer "status", limit: 1, null: false
    t.index ["nomor_telepon"], name: "nomor_telepon_UNIQUE", unique: true
  end

  create_table "mahasiswa", primary_key: "nim", id: { type: :string, limit: 500 }, charset: "utf8mb3", force: :cascade do |t|
    t.string "nama", limit: 500, null: false
    t.string "nomor_telepon", limit: 500, null: false
    t.index ["nim"], name: "nim_UNIQUE", unique: true
  end

  create_table "penanggungjawab", primary_key: "role", id: :integer, default: nil, charset: "utf8mb3", force: :cascade do |t|
    t.string "nama", limit: 500, null: false
    t.string "username", limit: 500, null: false
    t.string "password_digest", limit: 500, null: false
    t.string "nomor_telepon", limit: 500, null: false
    t.index ["role"], name: "role_UNIQUE", unique: true
  end

  create_table "penanggungjawabnonbeasiswa", primary_key: "nomor_induk", id: { type: :string, limit: 500 }, charset: "utf8mb3", force: :cascade do |t|
    t.string "nama", limit: 500, null: false
    t.string "nomor_telepon", limit: 500, null: false
    t.index ["nomor_induk"], name: "nomor_induk_UNIQUE", unique: true
  end

  create_table "penanggungjawabnonbeasiswa_has_penerimanonbeasiswa", primary_key: ["penanggung_jawab_non_beasiswa_id", "penerima_non_beasiswa_id"], charset: "utf8mb3", force: :cascade do |t|
    t.string "penanggung_jawab_non_beasiswa_id", limit: 500, null: false
    t.string "penerima_non_beasiswa_id", limit: 500, null: false
    t.index ["penanggung_jawab_non_beasiswa_id"], name: "fk_PenanggungJawabNonBeasiswa_has_PenerimaNonBeasiswa_Penan_idx"
    t.index ["penerima_non_beasiswa_id"], name: "fk_PenanggungJawabNonBeasiswa_has_PenerimaNonBeasiswa_Pener_idx"
  end

  create_table "penerimanonbeasiswa", primary_key: "nomor_induk", id: { type: :string, limit: 500 }, charset: "utf8mb3", force: :cascade do |t|
    t.string "nama", limit: 500, null: false
    t.string "nomor_telepon", limit: 500, null: false
    t.index ["nomor_induk"], name: "nomor_induk_UNIQUE", unique: true
  end

  create_table "penggalangandanabeasiswa", primary_key: ["penggalangan_dana_beasiswa_id", "penanggung_jawab_id"], charset: "utf8mb3", force: :cascade do |t|
    t.integer "penggalangan_dana_beasiswa_id", null: false
    t.string "deskripsi", limit: 500, null: false
    t.string "judul", limit: 500, null: false
    t.date "waktu_dimulai", null: false
    t.date "waktu_berakhir", null: false
    t.integer "kuota_beasiswa"
    t.integer "target_dana", null: false
    t.integer "target_penerima", null: false
    t.integer "total_nominal_terkumpul", null: false
    t.integer "status", limit: 1, null: false
    t.integer "penanggung_jawab_id", null: false
    t.index ["penanggung_jawab_id"], name: "fk_PenggalanganDanaBeasiswa_PenanggungJawab1_idx"
    t.index ["penggalangan_dana_beasiswa_id"], name: "penggalangan_dana_beasiswa_id_UNIQUE", unique: true
  end

  create_table "rekeningbank", primary_key: "nomor_rekening", id: { type: :string, limit: 500 }, charset: "utf8mb3", force: :cascade do |t|
    t.string "nama_bank", limit: 500, null: false
    t.string "nama_pemilik_rekening", limit: 500, null: false
    t.integer "penanggung_jawab_id"
    t.string "mahasiswa_id", limit: 500
    t.string "penerima_non_beasiswa_id", limit: 500
    t.string "donatur_id", limit: 500
    t.index ["donatur_id"], name: "fk_RekeningBank_Donatur1_idx"
    t.index ["mahasiswa_id"], name: "fk_RekeningBank_Mahasiswa1_idx"
    t.index ["nomor_rekening"], name: "nomor_rekening_UNIQUE", unique: true
    t.index ["penanggung_jawab_id"], name: "fk_RekeningBank_PenanggungJawab1_idx"
    t.index ["penerima_non_beasiswa_id"], name: "fk_RekeningBank_PenerimaNonBeasiswa1_idx"
  end

  add_foreign_key "bantuandanabeasiswa", "mahasiswa", primary_key: "nim", name: "fk_BantuanDanaBeasiswa_Mahasiswa1"
  add_foreign_key "bantuandanabeasiswa", "penggalangandanabeasiswa", column: "penggalangan_dana_beasiswa_id", primary_key: "penggalangan_dana_beasiswa_id", name: "fk_BantuanDanaBeasiswa_PenggalanganDanaBeasiswa1"
  add_foreign_key "bantuandananonbeasiswa", "penanggungjawabnonbeasiswa", column: "penanggung_jawab_non_beasiswa_id", primary_key: "nomor_induk", name: "fk_BantuanDanaNonBeasiswa_PenanggungJawabNonBeasiswa1"
  add_foreign_key "dokumensertifikat", "donatur", primary_key: "nomor_telepon", name: "fk_DokumenSertifikat_Donatur1"
  add_foreign_key "donasi", "bantuandananonbeasiswa", column: "bantuan_dana_non_beasiswa_id", primary_key: "bantuan_dana_non_beasiswa_id", name: "fk_Donasi_BantuanDanaNonBeasiswa1"
  add_foreign_key "donasi", "dokumensertifikat", column: "dokumen_sertifikat_id", primary_key: "jenis", name: "fk_Donasi_DokumenSertifikat1"
  add_foreign_key "donasi", "donatur", primary_key: "nomor_telepon", name: "fk_Donasi_Donatur1"
  add_foreign_key "donasi", "penggalangandanabeasiswa", column: "penggalangan_dana_beasiswa_id", primary_key: "penggalangan_dana_beasiswa_id", name: "fk_Donasi_PenggalanganDanaBeasiswa1"
  add_foreign_key "penanggungjawabnonbeasiswa_has_penerimanonbeasiswa", "penanggungjawabnonbeasiswa", column: "penanggung_jawab_non_beasiswa_id", primary_key: "nomor_induk", name: "fk_PenanggungJawabNonBeasiswa_has_PenerimaNonBeasiswa_Penangg1"
  add_foreign_key "penanggungjawabnonbeasiswa_has_penerimanonbeasiswa", "penerimanonbeasiswa", column: "penerima_non_beasiswa_id", primary_key: "nomor_induk", name: "fk_PenanggungJawabNonBeasiswa_has_PenerimaNonBeasiswa_Penerim1"
  add_foreign_key "penggalangandanabeasiswa", "penanggungjawab", column: "penanggung_jawab_id", primary_key: "role", name: "fk_PenggalanganDanaBeasiswa_PenanggungJawab1"
  add_foreign_key "rekeningbank", "donatur", primary_key: "nomor_telepon", name: "fk_RekeningBank_Donatur1"
  add_foreign_key "rekeningbank", "mahasiswa", primary_key: "nim", name: "fk_RekeningBank_Mahasiswa1"
  add_foreign_key "rekeningbank", "penanggungjawab", column: "penanggung_jawab_id", primary_key: "role", name: "fk_RekeningBank_PenanggungJawab1"
  add_foreign_key "rekeningbank", "penerimanonbeasiswa", column: "penerima_non_beasiswa_id", primary_key: "nomor_induk", name: "fk_RekeningBank_PenerimaNonBeasiswa1"
end
