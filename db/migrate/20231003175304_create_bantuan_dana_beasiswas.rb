class CreateBantuanDanaBeasiswas < ActiveRecord::Migration[6.1]
  def change
    create_table :BantuanDanaBeasiswa, id: false do |t|
      t.integer :bantuan_dana_beasiswa_id, null: false, primary_key: true 
      t.string  :alasan_butuh_bantuan, limit: 500, null: false
      t.integer :golongan_ukt, null: false
      t.string  :kuitansi_pembayaran_ukt, limit: 500, null: false
      t.integer :gaji_orang_tua, null: false
      t.string  :bukti_slip_gaji_orang_tua, limit: 500, null: false
      t.string  :esai, limit: 500, null: false
      t.integer :jumlah_tanggungan_keluarga, null: false
      t.string  :biaya_transportasi, limit: 500, null: false
      t.string  :biaya_internet, limit: 500, null: false
      t.string  :biaya_kos, limit: 500
      t.string  :biaya_konsumsi, limit: 500, null: false
      t.integer :total_pengeluaran_keluarga, null: false
      t.integer :penilaian_esai
      t.json    :nominal_penyaluran
      t.string  :dokumen_kehadiran_perkuliahan, limit: 500
      t.integer :status_pengajuan, null: false
      t.json    :status_penyaluran
      t.integer :status_kehadiran_perkuliahan
      
      t.string :mahasiswa_id, null: false
      t.integer :penggalangan_dana_beasiswa_id, null: false
      
      t.foreign_key :Mahasiswa, column: :mahasiswa_id, primary_key: :nim
      t.foreign_key :PenggalanganDanaBeasiswa, column: :penggalangan_dana_beasiswa_id, primary_key: :penggalangan_dana_beasiswa_id
      
      t.timestamps
    end
  end
end
