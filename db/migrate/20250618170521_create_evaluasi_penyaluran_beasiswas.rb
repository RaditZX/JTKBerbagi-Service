class CreateEvaluasiPenyaluranBeasiswas < ActiveRecord::Migration[7.0]
  def change
    create_table :evaluasi_penyaluran_beasiswas, id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.string :nim, limit: 500, null: false
      t.integer :bantuan_dana_beasiswa_id, null: false
      t.string :alasan, limit: 500
      t.string :dokumen_evaluasi, limit: 500
      t.date :tanggal_evaluasi, null: false, default: -> { 'CURRENT_DATE' }
      t.integer :status_evaluasi, null: false, default: 0 # 0: Pending, 1: Approved, 2: Rejected

      t.timestamps
    end

    # Tambahkan foreign key constraints
    add_foreign_key :evaluasi_penyaluran_beasiswas, :mahasiswa, column: :nim, primary_key: :nim,
                    name: "fk_evaluasi_penyaluran_beasiswas_mahasiswa"
    add_foreign_key :evaluasi_penyaluran_beasiswas, :bantuandanabeasiswas, column: :bantuan_dana_beasiswa_id,
                    primary_key: :bantuan_dana_beasiswa_id,
                    name: "fk_evaluasi_penyaluran_beasiswas_bantuan_dana_beasiswa"

    # Tambahkan indeks untuk performa dan unique constraint jika diperlukan
    add_index :evaluasi_penyaluran_beasiswas, :nim
    add_index :evaluasi_penyaluran_beasiswas, :bantuan_dana_beasiswa_id
    # Tambahkan unique constraint jika evaluasi per bantuan dan mahasiswa harus unik
    # add_index :evaluasi_penyaluran_beasiswas, [:nim, :bantuan_dana_beasiswa_id], unique: true, name: "unique_evaluasi_per_mahasiswa_bantuan"
  end
end