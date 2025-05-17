class CreateDokumenSertifikats < ActiveRecord::Migration[6.1]
  def change
    create_table :DokumenSertifikat, primary_key: ["jenis", "donatur_id"] do |t|
      t.integer :jenis, null: false
      t.string :donatur_id, limit: 500, null: false

      t.index :donatur_id, name: "fk_DokumenSertifikat_Donatur1_idx"

      t.timestamps
    end
  end
end
