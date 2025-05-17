class CreateDonasis < ActiveRecord::Migration[6.1]
  def change
    create_table :Donasi, primary_key: ["nomor_referensi", "donatur_id"] do |t|
      t.string :nomor_referensi, null: false
      t.string :donatur_id, null: false
      t.integer :nominal_donasi, null: false
      t.string :struk_pembayaran, limit: 500
      t.time :waktu_berakhir, null: false
      t.date :tanggal_approve
      t.integer :status, null: false
      t.integer :bantuan_dana_non_beasiswa_id
      t.integer :penggalangan_dana_beasiswa_id
      t.integer :dokumen_sertifikat_id

      t.index ["bantuan_dana_non_beasiswa_id"], name: "fk_Donasi_BantuanDanaNonBeasiswa1_idx"
      t.index ["dokumen_sertifikat_id"], name: "fk_Donasi_DokumenSertifikat1_idx"
      t.index ["donatur_id"], name: "fk_Donasi_Donatur1_idx"
      t.index ["nomor_referensi"], name: "nomor_referensi_UNIQUE", unique: true
      t.index ["penggalangan_dana_beasiswa_id"], name: "fk_Donasi_PenggalanganDanaBeasiswa1_idx"

      t.timestamps
    end
  end
end
