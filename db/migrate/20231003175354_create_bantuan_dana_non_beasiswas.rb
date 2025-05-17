class CreateBantuanDanaNonBeasiswas < ActiveRecord::Migration[6.1]
  def change
    create_table :BantuanDanaNonBeasiswa do |t|
      t.integer :bantuan_dana_non_beasiswa_id, null: false
      t.string :judul_galang_dana, limit: 500, null: false
      t.date :waktu_galang_dana, null: false
      t.string :deskripsi_galang_dana, limit: 500, null: false
      t.integer :dana_yang_dibutuhkan, null: false
      t.string :bukti_butuh_bantuan, limit: 500, null: false
      t.string :kategori, limit: 500, null: false
      t.integer :total_nominal_terkumpul
      t.integer :status_pengajuan, null: false
      t.integer :status_penyaluran
      t.string :penanggung_jawab_non_beasiswa_id, limit: 500, null: false

      t.index :bantuan_dana_non_beasiswa_id, unique: true, name: "bantuan_dana_non_beasiswa_id_UNIQUE"
      t.index :penanggung_jawab_non_beasiswa_id, name: "fk_BantuanDanaNonBeasiswa_PenanggungJawabNonBeasiswa1_idx"

      t.timestamps
    end
  end
end
