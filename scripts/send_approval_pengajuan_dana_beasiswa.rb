require_relative '../config/environment'
require_relative '../app/messages/send_approval_pengajuan_dana_beasiswa_notification'
require_relative '../app/services/twilio_whatsapp_sender'
require_relative '../app/utils/enums/status_pengajuan'

ActiveRecord::Base.transaction do
  begin
    # Bikin Mahasiswa
    mahasiswa = Mahasiswa.create!(
      nim: "12345678",
      nama: "Budi",
      nomor_telepon: "+6288905126629"
    )

    # Bikin PenanggungJawab
    penanggung_jawab = PenanggungJawab.create!(
      nama: "Pak Andi",
      role: Enums::RolePenanggungJawab::JTK_BERBAGI,
      username: "andi_jtk",
      password: "password123",
      nomor_telepon: "+6288905126629"
    )

    # Bikin PenggalanganDanaBeasiswa
    penggalangan_dana_beasiswa = PenggalanganDanaBeasiswa.create!(
      penggalangan_dana_beasiswa_id: SecureRandom.uuid,
      judul: "Program Beasiswa JTK 2025",
      deskripsi: "Beasiswa untuk mahasiswa berprestasi",
      target_dana: 100_000_000,
      target_penerima: 10,
      penanggung_jawab: penanggung_jawab,
      status: Enums::StatusPenggalanganDanaBeasiswa::ONGOING,
      waktu_dimulai: DateTime.now,
      waktu_berakhir: DateTime.now + 30.days,
      total_nominal_terkumpul: 0
    )

    # Bikin BantuanDanaBeasiswa
    bantuan_dana_beasiswa = BantuanDanaBeasiswa.create!(
      bantuan_dana_beasiswa_id: SecureRandom.uuid,
      mahasiswa: mahasiswa,
      penggalangan_dana_beasiswa: penggalangan_dana_beasiswa,
      alasan_butuh_bantuan: "Butuh biaya kuliah",
      golongan_ukt: "1",
      kuitansi_pembayaran_ukt: "kuitansi.pdf",
      gaji_orang_tua: 5_000_000,
      bukti_slip_gaji_orang_tua: "slip.pdf",
      esai: "Esai motivasi",
      jumlah_tanggungan_keluarga: 4,
      biaya_transportasi: 200_000,
      biaya_konsumsi: 300_000,
      biaya_internet: 100_000,
      total_pengeluaran_keluarga: 1_000_000,
      status_pengajuan: Enums::StatusPengajuan::REJECTED
    )

    # Kirim pesan
    result = SendApprovalPengajuanDanaBeasiswa.new(bantuan_dana_beasiswa: bantuan_dana_beasiswa).call

    if result[:success]
      puts "Pesan berhasil dikirim ke +6288905126629 pada #{Time.now.strftime('%Y-%m-%d %H:%M:%S %Z')}!"
    else
      puts "Gagal mengirim pesan: #{result[:error]}"
    end

    raise ActiveRecord::Rollback
  rescue StandardError => e
    Rails.logger.error("[Skrip] Error: #{e.message}")
    raise ActiveRecord::Rollback
  end
end