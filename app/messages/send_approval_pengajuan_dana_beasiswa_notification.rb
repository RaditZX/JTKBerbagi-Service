class SendApprovalPengajuanDanaBeasiswa
  def initialize(bantuan_dana_beasiswa:)
    @bantuan_dana_beasiswa = bantuan_dana_beasiswa
    @mahasiswa = bantuan_dana_beasiswa.mahasiswa
  end

  def call
    return { success: false, error: "Bantuan dana beasiswa tidak ditemukan" } if @bantuan_dana_beasiswa.nil?
    return { success: false, error: "Mahasiswa tidak ditemukan" } if @mahasiswa.nil?

    # Gunakan enum
    return { success: false, error: "Proses seleksi belum selesai" } unless @bantuan_dana_beasiswa.status_pengajuan.in?([Enums::StatusPengajuan::APPROVED, Enums::StatusPengajuan::DONE])

    message = <<~TEXT
      [Notifikasi Pengajuan Dana Beasiswa]

      Halo #{@mahasiswa.nama},

      Pengajuan dana beasiswa Anda telah selesai diproses.
      - Nama Pengaju: #{@mahasiswa.nama}
      - Nomor Telepon: #{@mahasiswa.nomor_telepon}
      - Jenis Pengajuan: Beasiswa
      - Status Pengajuan: #{@bantuan_dana_beasiswa.status_pengajuan == Enums::StatusPengajuan::APPROVED ? "Diterima" : "Ditolak"}

      Terima kasih telah mengikuti program JTK Berbagi 🙏
    TEXT

    begin
      TwilioWhatsappSender.new(
        to: @mahasiswa.nomor_telepon,
        body: message
      ).call

      { success: true }
    rescue => e
      Rails.logger.error("[WhatsApp] Gagal mengirim notifikasi pengajuan beasiswa: #{e.message}")
      { success: false, error: e.message }
    end
  end
end