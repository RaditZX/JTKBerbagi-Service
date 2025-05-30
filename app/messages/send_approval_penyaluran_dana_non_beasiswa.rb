# app/messages/send_penyaluran_dana_non_beasiswa_notification.rb
class SendApprovalPenyaluranDanaNonBeasiswa
  def initialize(bantuan_dana:)
    @bantuan_dana = bantuan_dana
    @penanggung_jawab = bantuan_dana.penanggung_jawab_non_beasiswa
  end

  def call
    return { success: false, error: "Bantuan dana tidak ditemukan" } if @bantuan_dana.nil?
    return { success: false, error: "Penanggung jawab tidak ditemukan" } if @penanggung_jawab.nil?

    message = <<~TEXT
      [Konfirmasi Penyaluran Dana]

      Halo #{@penanggung_jawab.nama},

      Kami ingin menginformasikan bahwa dana non-beasiswa dengan judul:
      "#{@bantuan_dana.judul_galang_dana}"

      Telah berhasil disalurkan kepada penerima bantuan.

      Terima kasih atas peran Anda sebagai penanggung jawab dalam program JTK Berbagi 🙏
    TEXT

    begin
      TwilioWhatsappSender.new(
        to: @penanggung_jawab.nomor_telepon,
        body: message
      ).call

      { success: true }
    rescue => e
      Rails.logger.error("[WhatsApp] Gagal mengirim notifikasi penyaluran dana non-beasiswa: #{e.message}")
      { success: false, error: e.message }
    end
  end
end
