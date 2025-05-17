class Donasi < ApplicationRecord
  self.table_name = 'donasi'
  self.primary_key = 'nomor_referensi'

  belongs_to :penggalangan_dana_beasiswa, class_name: "PenggalanganDanaBeasiswa", optional: true
  belongs_to :bantuan_dana_non_beasiswa, class_name: "BantuanDanaNonBeasiswa", optional: true
  belongs_to :donatur, class_name: "Donatur"
  belongs_to :dokumen_sertifikat, class_name: "DokumenSertifikat", optional: true
  

  validates :nominal_donasi, presence: true

  scope :new_donation, -> { where(status: Enums::StatusDonasi::NEW)}
  scope :expired, -> { where(status: Enums::StatusDonasi::EXPIRED)}
  scope :approved, -> { where(status: Enums::StatusDonasi::APPROVED)}
end
