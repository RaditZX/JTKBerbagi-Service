class NotifikasiDonasiService
  def self.kirim_notifikasi(donasi)
    return { success: false, error: 'Invalid status' } unless [
      Enums::StatusDonasi::NEW,
      Enums::StatusDonasi::APPROVED,
      Enums::StatusDonasi::REJECTED,
      Enums::StatusDonasi::DONE,
      Enums::StatusDonasi::EXPIRED
    ].include?(donasi.status)

    judul = donasi.judul_donation
    nama = donasi.donatur.nama
    nomor_telepon = donasi.donatur.nomor_telepon
    nominal = donasi.nominal_donasi

    status_text = case donasi.status
                  when Enums::StatusDonasi::NEW
                    "sedang kami proses"
                  when Enums::StatusDonasi::APPROVED
                    "telah berhasil dan dikonfirmasi"
                  when Enums::StatusDonasi::REJECTED
                    "ditolak karena tidak memenuhi syarat"
                  when Enums::StatusDonasi::DONE
                    "telah selesai dan dana telah diterima"
                  when Enums::StatusDonasi::EXPIRED
                    "gagal diproses karena melebihi batas waktu"
                  else
                    donasi.status.to_s
                  end

    pesan = <<~PESAN
      Hai #{nama}! 👋

      Terima kasih sudah berdonasi untuk program *#{judul}*. Kami sangat menghargai dukungan Anda. 🤝

      Donasi sebesar Rp#{nominal.to_s(:delimited)} saat ini *#{status_text}*.

      Jika ada pertanyaan atau butuh bantuan, silakan hubungi kami kapan saja ya.

      Salam hangat,
      JTK Berbagi
    PESAN

    begin
      result = TwilioWhatsappSender.new(
        to: nomor_telepon,
        body: pesan.strip
      ).call
      Rails.logger.error("Notification failed: #{result[:error]}") unless result[:success]
      result
    rescue StandardError => e
      Rails.logger.error("Notification error: #{e.message}")
      { success: false, error: e.message }
    end
  end
end