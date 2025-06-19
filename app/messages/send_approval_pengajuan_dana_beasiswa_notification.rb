class SendApprovalPengajuanDanaBeasiswa
  def initialize(bantuan_dana_beasiswa:)
    @bantuan_dana_beasiswa = bantuan_dana_beasiswa
    @mahasiswa = bantuan_dana_beasiswa.mahasiswa
  end

  def call
    return { success: false, error: "Bantuan dana beasiswa tidak ditemukan" } if @bantuan_dana_beasiswa.nil?
    return { success: false, error: "Mahasiswa tidak ditemukan" } if @mahasiswa.nil?

    # PERBAIKAN 1: Tambahkan REJECTED ke dalam kondisi pengecek
    unless @bantuan_dana_beasiswa.status_pengajuan.in?([
      Enums::StatusPengajuan::APPROVED, 
      Enums::StatusPengajuan::REJECTED,  # ← TAMBAHAN INI
      Enums::StatusPengajuan::DONE
    ])
      return { success: false, error: "Proses seleksi belum selesai" }
    end

    # PERBAIKAN 2: Gunakan case statement untuk menentukan status text
    status_text = case @bantuan_dana_beasiswa.status_pengajuan
                  when Enums::StatusPengajuan::APPROVED then "Diterima"
                  when Enums::StatusPengajuan::REJECTED then "Ditolak"
                  when Enums::StatusPengajuan::DONE then "Selesai"
                  else "Unknown"
                  end

    message = <<~TEXT
      [Notifikasi Pengajuan Dana Beasiswa]

      Halo #{@mahasiswa.nama},

      Pengajuan dana beasiswa Anda telah selesai diproses.
      - Nama Pengaju: #{@mahasiswa.nama}
      - Nomor Telepon: #{@mahasiswa.nomor_telepon}
      - Judul Pengajuan : #{@bantuan_dana_beasiswa.penggalangan_dana_beasiswa.judul}
      - Status Pengajuan: #{status_text}

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