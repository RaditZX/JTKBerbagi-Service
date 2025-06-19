class SendApprovalPengajuanDanaNonBeasiswa
  def initialize(bantuan_dana_non_beasiswa:)
    @bantuan_dana_non_beasiswa = bantuan_dana_non_beasiswa
    @penanggung_jawab = bantuan_dana_non_beasiswa.penanggung_jawab_non_beasiswa
  end

  def call
    return { success: false, error: "Bantuan dana non-beasiswa tidak ditemukan" } if @bantuan_dana_non_beasiswa.nil?
    return { success: false, error: "Penanggung jawab tidak ditemukan" } if @penanggung_jawab.nil?

    # PERBAIKAN 1: Tambahkan REJECTED ke dalam kondisi pengecek
    unless @bantuan_dana_non_beasiswa.status_pengajuan.in?([
      Enums::StatusPengajuan::APPROVED, 
      Enums::StatusPengajuan::REJECTED,  # ← TAMBAHAN INI
      Enums::StatusPengajuan::DONE
    ])
      return { success: false, error: "Proses seleksi belum selesai" }
    end

    # PERBAIKAN 2: Gunakan case statement untuk menentukan status text
    status_text = case @bantuan_dana_non_beasiswa.status_pengajuan
                  when Enums::StatusPengajuan::APPROVED then "Diterima"
                  when Enums::StatusPengajuan::REJECTED then "Ditolak"
                  when Enums::StatusPengajuan::DONE then "Selesai"
                  else "Unknown"
                  end

    message = <<~TEXT
      [Notifikasi Pengajuan Dana Non-Beasiswa]

      Halo #{@penanggung_jawab.nama},

      Pengajuan dana non-beasiswa dengan judul "#{@bantuan_dana_non_beasiswa.judul_galang_dana}" telah selesai diproses.
      - Nama Pengaju: #{@penanggung_jawab.nama} (Penanggung Jawab)
      - Nomor Telepon: #{@penanggung_jawab.nomor_telepon}
      - Jenis Pengajuan: Non-Beasiswa
      - Status Pengajuan: #{status_text}

      Terima kasih atas peran Anda dalam program JTK Berbagi 🙏
    TEXT

    begin
      result = TwilioWhatsappSender.new(
        to: @penanggung_jawab.nomor_telepon,
        body: message
      ).call

      return result if result[:success] == false
      { success: true }
    rescue => e
      Rails.logger.error("[WhatsApp] Gagal mengirim notifikasi pengajuan non-beasiswa: #{e.message}")
      { success: false, error: e.message }
    end
  end
end