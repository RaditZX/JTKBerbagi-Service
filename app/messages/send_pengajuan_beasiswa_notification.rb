class SendPengajuanBeasiswaNotification
  def initialize(mahasiswa:, bantuan_dana:, penggalangan_dana:)
    @mahasiswa = mahasiswa
    @bantuan_dana = bantuan_dana
    @penggalangan_dana = penggalangan_dana
  end

  def call
    pesan = "Halo #{@mahasiswa.nama},\n" \
            "Pengajuan Bantuan Dana Beasiswa Anda berhasil didaftarkan dengan ID: #{@penggalangan_dana.judul}.\n" \
            "Status saat ini: #{@bantuan_dana.status_pengajuan}.\n\n" \
            "Kami akan menghubungi Anda untuk informasi selanjutnya."

    TwilioWhatsappSender.new(
      to: @mahasiswa.nomor_telepon, # Pastikan `nomor_telepon` ada dan valid
      body: pesan
    ).call
  end
end
