class PenanggungJawabNonBeasiswa < ApplicationRecord
  self.table_name = 'penanggungjawabnonbeasiswa'
  self.primary_key = 'nomor_induk'

  has_many :penanggungjawabnonbeasiswa_has_penerimanonbeasiswa, class_name: "PenanggungJawabNonBeasiswaHasPenerimaNonBeasiswa"
  has_many :penerima_non_beasiswa, class_name: "PenerimaNonBeasiswa", through: :penanggungjawabnonbeasiswa_has_penerimanonbeasiswa
  has_many :bantuan_dana_non_beasiswa, class_name: "BantuanDanaNonBeasiswa"

  validates :nama, presence: true
  validates :nomor_induk, presence: true
  validates :nomor_telepon, presence: true
end
