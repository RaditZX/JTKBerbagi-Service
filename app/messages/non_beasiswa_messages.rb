# messages/non_beasiswa_messages.rb
module NonBeasiswaMessages
  module_function

  def bantuan_dana_non_beasiswa_disetujui(penerima_name)
    "Halo #{penerima_name}, pengajuan bantuan dana non-beasiswa kamu telah disetujui. Silakan cek detail penyaluran bantuan pada dashboard."
  end

  def status_penyaluran_dana_non_beasiswa(penerima_name)
    "Halo #{penerima_name}, bantuan dana non-beasiswa kamu telah disalurkan. Silakan cek rekening terdaftar."
  end
end
