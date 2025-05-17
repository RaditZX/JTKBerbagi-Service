class Donatur < ApplicationRecord
  self.table_name = 'donatur'
  self.primary_key = 'nomor_telepon'

  has_many :donasi, class_name: "Donasi"
  has_many :rekening_bank, class_name: "RekeningBank"
  has_many :dokumen_sertifikat, class_name: "DokumenSertifikat"

  validates :nama, presence: true
  validates :nomor_telepon, presence: true

  has_secure_password
  validates :password, length: {minimum: 8 }, if: -> { new_record? || password.nil? }  
  
  scope :donatur_registered, -> { where(status: 1)}
end
