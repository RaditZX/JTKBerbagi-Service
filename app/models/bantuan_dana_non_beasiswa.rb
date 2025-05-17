class BantuanDanaNonBeasiswa < ApplicationRecord
  self.table_name = 'bantuandananonbeasiswa'
  self.primary_key = 'bantuan_dana_non_beasiswa_id'

  belongs_to :penanggung_jawab_non_beasiswa, class_name: "PenanggungJawabNonBeasiswa"
  has_many :donasi, class_name: "Donasi"

  validates :waktu_galang_dana, presence: true
  validates :judul_galang_dana, presence: true
  validates :deskripsi_galang_dana, presence: true
  validates :dana_yang_dibutuhkan, presence: true
  validates :bukti_butuh_bantuan, presence: true
  validates_inclusion_of :kategori, in: %w(Medis Bencana Duka), message: "harus Medis/Bencana/Duka!"
  
  scope :pengajuan_baru, -> { where(status_pengajuan: Enums::StatusPengajuan::NEW)}
  scope :pengajuan_approved, -> { where(status_pengajuan: Enums::StatusPengajuan::APPROVED)}
  scope :pengajuan_done, -> { where(status_pengajuan: Enums::StatusPengajuan::DONE).where(status_penyaluran:Enums::StatusPenyaluran::DELIVERED)}
  scope :rekapitulasi, -> { where("status_pengajuan = #{Enums::StatusPengajuan::DONE} or status_penyaluran = #{Enums::StatusPenyaluran::PENDING} or status_penyaluran = #{Enums::StatusPenyaluran::DELIVERED}") }
  scope :penyaluran, -> { where(status_pengajuan: Enums::StatusPengajuan::DONE).where(status_penyaluran:Enums::StatusPenyaluran::PENDING)}
end
