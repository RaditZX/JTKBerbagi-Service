class CreateEvaluasiPenyaluranBeasiswas < ActiveRecord::Migration[6.1]
  def change
    create_table :evaluasi_penyaluran_beasiswas, id: false do |t|
      t.integer :evaluasi_penyaluran_beasiswa_id, null: false
      t.string :mahasiswa_id, limit: 500, null: false # Sesuaikan dengan tipe varchar(500) di tabel mahasiswa
      t.integer :bantuan_dana_beasiswa_id, null: false
      t.string :alasan, limit: 500
      t.string :dokumen_evaluasi, limit: 500
      t.date :tanggal_evaluasi, null: false
      t.boolean :status_penyaluran, null: false, default: false # 0: Pending, 1: Approved, 2: Rejected

      t.timestamps
    end

    # Tambahkan primary key secara eksplisit
    execute "ALTER TABLE evaluasi_penyaluran_beasiswas ADD PRIMARY KEY (evaluasi_penyaluran_beasiswa_id);"

    # Tambahkan foreign key constraints setelah tabel dibuat
    add_foreign_key :evaluasi_penyaluran_beasiswas, :mahasiswa, column: :mahasiswa_id, primary_key: :nim,
                    name: "fk_evaluasi_penyaluran_beasiswas_mahasiswa"
    add_foreign_key :evaluasi_penyaluran_beasiswas, :bantuandanabeasiswa, column: :bantuan_dana_beasiswa_id,
                    primary_key: :bantuan_dana_beasiswa_id,
                    name: "fk_evaluasi_penyaluran_beasiswas_bantuan_dana_beasiswa"
  end
end