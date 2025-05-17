class CreateDonaturs < ActiveRecord::Migration[6.1]
  def change
    create_table :Donatur, primary_key: "nomor_telepon", id: { type: :string, limit: 500 }do |t|
      t.string :nama, limit: 500, null: false
      t.string :password_digest, limit: 500
      t.integer :status, limit: 1, null: false
      t.timestamps
    end
  end
end
