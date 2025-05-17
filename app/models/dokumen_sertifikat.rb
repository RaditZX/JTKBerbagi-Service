class DokumenSertifikat < ApplicationRecord
  self.table_name = 'dokumensertifikat'
  self.primary_key = 'jenis'

  belongs_to :donatur, class_name: "Donatur"
  has_many :donasi, class_name: "Donasi"
end
