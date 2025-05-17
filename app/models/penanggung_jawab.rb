class PenanggungJawab < ApplicationRecord
    self.table_name = 'penanggungjawab'
    self.primary_key = 'role'

    has_many :rekening_bank, class_name: "RekeningBank"
    has_many :penggalangan_dana_beasiswa, class_name: "PenggalanganDanaBeasiswa"

    validates :nama, presence: true
    validates :role, presence: true
    validates :username, presence: true
    has_secure_password
    validates :password, length: {minimum: 8 }, if: -> { new_record? || password.nil? }
    validates :nomor_telepon, presence: true

    scope :penanggung_jawab_jtk_berbagi, -> { where(role: Enums::RolePenanggungJawab::JTK_BERBAGI)}
end
