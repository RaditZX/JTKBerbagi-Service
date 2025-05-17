class CreatePenggalanganDanaBeasiswas < ActiveRecord::Migration[6.1]
  def change
    create_table :PenggalanganDanaBeasiswa, id: false do |t|
      t.primary_key :penggalangan_dana_beasiswa_id, :integer
      t.text :deskripsi
      t.string :judul
      t.date :waktu_dimulai
      t.date :waktu_berakhir
      t.integer :kuota_beasiswa
      t.bigint :target_dana
      t.integer :target_jumlah_penerima
      t.integer :total_nominal_terkumpul
      t.decimal :status

      t.integer :penanggung_jawabs_role, null: false
      t.foreign_key :PenanggungJawab, column: :penanggung_jawabs_role, primary_key: :role

      t.timestamps
    end
  end
end
