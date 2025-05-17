class CreateMahasiswas < ActiveRecord::Migration[6.1]
  def change
    create_table :Mahasiswa, id: false do |t|
      t.string :nim, primary_key: true, limit: 9
      t.string :nama
      t.string :nomor_telepon, limit: 15
      t.timestamps
    end
  end
end
