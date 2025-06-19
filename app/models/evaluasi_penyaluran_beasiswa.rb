class EvaluasiPenyaluranBeasiswa < ApplicationRecord
  self.table_name = 'evaluasi_penyaluran_beasiswas'
  self.primary_key = 'evaluasi_penyaluran_beasiswa_id'

  belongs_to :mahasiswa, foreign_key: :mahasiswa_id, primary_key: :nim
  belongs_to :bantuan_dana_beasiswa, foreign_key: :bantuan_dana_beasiswa_id,
             primary_key: :bantuan_dana_beasiswa_id

  validates :mahasiswa_id, presence: true
  validates :bantuan_dana_beasiswa_id, presence: true
  validates :alasan, length: { maximum: 500 }
  validates :dokumen_evaluasi, length: { maximum: 500 }
  validates :tanggal_evaluasi, presence: true
  # validates :status_penyaluran, presence: true, inclusion: { in: 0..1 } # 0: Pending, 1: Approved, 2: Rejected

  # Opsional: Integrasi dengan Active Storage untuk dokumen
  has_one_attached :dokumen_evaluasi_file
end