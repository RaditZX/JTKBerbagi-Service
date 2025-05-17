class CreatePenanggungJawabNonBeasiswaHasPenerimaNonBeasiswas < ActiveRecord::Migration[6.1]
  def change
    create_table :PenanggungJawabNonBeasiswaHasPenerimaNonBeasiswa do |t|
      t.string :penanggung_jawab_non_beasiswa_id, limit: 500, null: false
      t.string :penerima_non_beasiswa_id, limit: 500, null: false

      t.index :penanggung_jawab_non_beasiswa_id, name: "penanggung_jawab_non_beasiswa_idx"
      t.index :penerima_non_beasiswa_id, name: "penerima_non_beasiswa_idx"
      
      t.timestamps
    end
  end
end
