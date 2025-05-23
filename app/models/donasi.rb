class Donasi < ApplicationRecord
  self.table_name = 'donasi'
  self.primary_key = 'nomor_referensi'

  belongs_to :penggalangan_dana_beasiswa, class_name: "PenggalanganDanaBeasiswa", optional: true
  belongs_to :bantuan_dana_non_beasiswa, class_name: "BantuanDanaNonBeasiswa", optional: true
  belongs_to :donatur, class_name: "Donatur"
  belongs_to :dokumen_sertifikat, class_name: "DokumenSertifikat", optional: true

  validate :minimal_nominal_donasi

  # Midtrans-related statuses
  enum payment_status: {
    pending: 0,
    processing: 1,
    success: 2,
    failed: 3,
    expired: 4
  }

  scope :new_donation, -> { where(status: Enums::StatusDonasi::NEW) }
  scope :expired, -> { where(status: Enums::StatusDonasi::EXPIRED) }
  scope :approved, -> { where(status: Enums::StatusDonasi::APPROVED) }

  def generate_midtrans_token
    payload = {
      transaction_details: {
        order_id: nomor_referensi,
        gross_amount: nominal_donasi.to_i
      },
      customer_details: {
        first_name: donatur.nama,
        phone: donatur.nomor_telepon,
      },
      item_details: [
        {
          id: nomor_referensi,
          name: judul_donation,
          quantity: 1,
          price: nominal_donasi.to_i
        }
      ]
    }

    # buat snap token
    Midtrans.create_snap_token(payload)
  end

  private

  def judul_donation
    if penggalangan_dana_beasiswa.present?
      penggalangan_dana_beasiswa.judul
    elsif bantuan_dana_non_beasiswa.present?
      bantuan_dana_non_beasiswa.judul_galang_dana
    else
      'Donasi'
    end
  end
end