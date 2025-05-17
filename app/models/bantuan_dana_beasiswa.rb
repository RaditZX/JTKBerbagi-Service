class BantuanDanaBeasiswa < ApplicationRecord
  self.table_name = 'bantuandanabeasiswa'
  self.primary_key = 'bantuan_dana_beasiswa_id'

  belongs_to :penggalangan_dana_beasiswa, class_name: "PenggalanganDanaBeasiswa"
  belongs_to :mahasiswa, class_name: "Mahasiswa"

  validates :alasan_butuh_bantuan, presence: true
  validates :golongan_ukt, presence: true
  validates :kuitansi_pembayaran_ukt, presence: true
  validates :gaji_orang_tua, presence: true
  validates :bukti_slip_gaji_orang_tua, presence: true
  validates :esai, presence: true
  validates :jumlah_tanggungan_keluarga, presence: true
  validates :biaya_transportasi, presence: true
  validates :biaya_konsumsi, presence: true
  validates :biaya_internet, presence: true
  validates :total_pengeluaran_keluarga, presence: true

  scope :pengajuan_baru, -> { where(status_pengajuan: Enums::StatusPengajuan::NEW)}
  scope :pengajuan_approved, -> { where(status_pengajuan: Enums::StatusPengajuan::APPROVED)}
  scope :pengajuan_done, -> { where(status_pengajuan: Enums::StatusPengajuan::DONE).where.not("JSON_CONTAINS(status_penyaluran, ?, '$')", [Enums::StatusPenyaluran::PENDING].to_json)}
  scope :rekapitulasi, -> { where("status_pengajuan = #{Enums::StatusPengajuan::APPROVED} or status_pengajuan = #{Enums::StatusPengajuan::DONE} ")}

end
