class SendPenerimaBeasiswaNotification
  def initialize(bantuan_dana_beasiswa)
    @bantuan = bantuan_dana_beasiswa
    @mahasiswa = bantuan_dana_beasiswa.mahasiswa
    @penggalangan = bantuan_dana_beasiswa.penggalangan_dana_beasiswa
  end

  def call
    return { success: false, error: "Mahasiswa tidak memiliki nomor telepon" } if @mahasiswa.nomor_telepon.blank?

    total_nominal = @penggalangan.donasi.sum(:nominal_donasi)
    message = build_message(total_nominal)

    result = TwilioWhatsappSender.new(
      to: @mahasiswa.nomor_telepon,
      body: message
    ).call

    puts "Twilio result: #{result.inspect}"

    return { success: true } if result[:success]

    { success: false, error: result[:error] }
  end

  private

  def build_message(nominal)
    <<~TEXT
      Halo #{@mahasiswa.nama}!

      Selamat 🎉 Kamu telah terpilih sebagai penerima Beasiswa "#{@penggalangan.judul}" pada batch terbaru.

      📌 NIM: #{@mahasiswa.nim}
      📌 Judul Beasiswa: #{@penggalangan.judul}
      📌 Batch: 2025 - 02
      💰 Total Dana Beasiswa: Rp#{format_rupiah(nominal)}

      Silakan cek email atau hubungi panitia untuk informasi lebih lanjut.

      - JTK Berbagi
    TEXT
  end

  def format_rupiah(amount)
    ActionController::Base.helpers.number_to_currency(amount, unit: '', separator: ',', delimiter: '.')
  end
end
