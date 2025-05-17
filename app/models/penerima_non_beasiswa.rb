class PenerimaNonBeasiswa < ApplicationRecord
  self.table_name = 'penerimanonbeasiswa'
  self.primary_key = 'nomor_induk'
  
  has_many :penanggungjawabnonbeasiswa_has_penerimanonbeasiswa, class_name: "PenanggungJawabNonBeasiswaHasPenerimaNonBeasiswa"
  has_many :penanggung_jawab_non_beasiswa, class_name: "PenanggungJawabNonBeasiswa", through: :penanggungjawabnonbeasiswa_has_penerimanonbeasiswa

  validates :nama, presence: true
  validates :nomor_induk, presence: true
  validates :nomor_telepon, presence: true
end
