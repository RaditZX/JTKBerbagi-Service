class CreatePenanggungJawabs < ActiveRecord::Migration[6.1]
  def change
    create_table :PenanggungJawab, primary_key: "role", id: :integer, default: nil do |t|
      t.string :nama, limit: 500, null: false
      t.string :username, limit: 500, null: false
      t.string :password_digest, limit: 500, null: false
      t.string :nomor_telepon, limit: 500, null: false

      t.index :role, unique: true, name: "role_UNIQUE"
      t.timestamps
    end
  end
end
