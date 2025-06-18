# messages/beasiswa_messages.rb
module BeasiswaMessages
  module_function

  def bantuan_dana_beasiswa_disetujui(mahasiswa_name)
    "Halo #{mahasiswa_name}, pengajuan bantuan dana beasiswa kamu telah disetujui. Silakan cek dashboard kamu untuk informasi lebih lanjut."
  end

  def status_penyaluran_dana_mahasiswa(mahasiswa_name)
    "Halo #{mahasiswa_name}, dana beasiswa kamu telah disalurkan. Silakan cek rekening yang telah didaftarkan."
  end
end
