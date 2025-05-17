class CreateCivitasAkademikas < ActiveRecord::Migration[6.1]
  def change
    create_table :CivitasAkademika, primary_key: :nomor_induk, id: :string, limit: 500, charset: "utf8mb3" do |t|
      t.string :nama, limit: 500, null: false
      t.timestamps
    end
  end
end
