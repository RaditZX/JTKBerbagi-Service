class CivitasAkademika < ApplicationRecord
  self.table_name = 'civitasakademika' # Required due to non-standard table name
  self.primary_key = 'nomor_induk' # Set primary key

  validates :nomor_induk, presence: true, uniqueness: true, format: { with: /\A\d{9}\z/, message: "must be a number" }
  validates :nama, presence: true, format: {with: /\A[a-zA-Z\s]+\z/, message: "must contain only letters"}
end