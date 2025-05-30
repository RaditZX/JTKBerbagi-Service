class NotifikasiDonasiService
  def self.kirim_notifikasi(donasi)
    return unless [Enums::StatusDonasi::NEW, Enums::StatusDonasi::EXPIRED, Enums::StatusDonasi::APPROVED].include?(donasi.status)

    judul = donasi.judul_galang_dana
    nama = donasi.donatur.nama
    nomor_telepon = donasi.donatur.nomor_telepon
    nominal = donasi.nominal_donasi

    status_text = case donasi.status
                  when Enums::StatusDonasi::NEW
                    "sedang kami proses"
                  when Enums::StatusDonasi::EXPIRED
                    "gagal diproses karena melebihi batas waktu"
                  when Enums::StatusDonasi::APPROVED
                    "telah berhasil dan dikonfirmasi"
                  else
                    donasi.status
                  end

    pesan = <<~PESAN
      Hai #{nama}! 👋

      Terima kasih sudah berdonasi untuk program *#{judul}*. Kami sangat menghargai dukungan Anda. 🤝

      Donasi sebesar Rp#{nominal.to_s(:delimited)} saat ini *#{status_text}*.

      Jika ada pertanyaan atau butuh bantuan, silakan hubungi kami kapan saja ya.

      Salam hangat,
      JTK Berbagi
    PESAN

    TwilioWhatsappSender.new(
      to: nomor_telepon,
      body: pesan.strip
    ).call
  end
end
