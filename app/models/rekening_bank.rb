class RekeningBank < ApplicationRecord
    self.table_name = 'rekeningbank'
    self.primary_key = 'nomor_rekening'
    belongs_to :penanggung_jawab, class_name: "PenanggungJawab", optional: true
    belongs_to :mahasiswa, class_name: "Mahasiswa", optional: true
    belongs_to :penerima_non_beasiswa, class_name: "PenerimaNonBeasiswa", optional: true
    belongs_to :donatur, class_name: "Donatur", optional: true

    validates :nama_bank, presence: true
    validates :nomor_rekening, presence: true
    validates :nama_pemilik_rekening, presence: true
end
