class CreatePenanggungJawabNonBeasiswas < ActiveRecord::Migration[6.0]
  def change
    create_table :PenanggungJawabNonBeasiswa, id: false, options: "CHARSET=utf8mb3" do |t|
      t.string :nomor_induk, limit: 500, null: false, primary_key: true
      t.string :nama, limit: 500, null: false
      t.string :nomor_telepon, limit: 500, null: false

      t.index :nomor_induk, unique: true, name: "nomor_induk_UNIQUE"
    end
  end
end
