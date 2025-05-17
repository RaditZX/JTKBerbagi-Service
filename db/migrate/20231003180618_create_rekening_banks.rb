class CreateRekeningBanks < ActiveRecord::Migration[6.0]
  def change
    create_table :RekeningBank, id: false, options: "CHARSET=utf8mb3" do |t|
      t.string :nomor_rekening, limit: 500, null: false, primary_key: true
      t.string :nama_bank, limit: 500, null: false
      t.string :nama_pemilik_rekening, limit: 500, null: false

      t.integer :penanggung_jawab_id
      t.string :mahasiswa_id, limit: 500
      t.string :penerima_non_beasiswa_id, limit: 500
      t.string :donatur_id, limit: 500

      t.index :donatur_id, name: "fk_RekeningBank_Donatur1_idx"
      t.index :mahasiswa_id, name: "fk_RekeningBank_Mahasiswa1_idx"
      t.index :nomor_rekening, unique: true, name: "nomor_rekening_UNIQUE"
      t.index :penanggung_jawab_id, name: "fk_RekeningBank_PenanggungJawab1_idx"
      t.index :penerima_non_beasiswa_id, name: "fk_RekeningBank_PenerimaNonBeasiswa1_idx"
    end
  end
end
