class Mahasiswa < ApplicationRecord
    self.table_name = 'mahasiswa'
    self.primary_key = 'nim'
    
    has_many :bantuan_dana_beasiswa, class_name: "BantuanDanaBeasiswa"
    has_many :rekening_bank, class_name: "RekeningBank"

    validates :nim, presence: true
    validates :nama, presence: true
    validates :nomor_telepon, presence: true
end
