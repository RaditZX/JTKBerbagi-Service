require_relative '../config/environment'
require_relative '../app/messages/send_approval_pengajuan_dana_non_beasiswa_notification'
require_relative '../app/services/twilio_whatsapp_sender'
require_relative '../app/utils/enums/status_pengajuan'

ActiveRecord::Base.transaction do
  begin
    # Cek atau bikin PenanggungJawabNonBeasiswa
    nomor_induk = "PJ001"
    penanggung_jawab = PenanggungJawabNonBeasiswa.find_or_create_by!(
      nomor_induk: nomor_induk
    ) do |pj|
      pj.nama = "Romli"
      pj.nomor_telepon = "+6288905126629"
    end

    # Cek atau bikin BantuanDanaNonBeasiswa
    bantuan_dana_non_beasiswa = BantuanDanaNonBeasiswa.find_or_create_by!(
      penanggung_jawab_non_beasiswa: penanggung_jawab,
      status_pengajuan: Enums::StatusPengajuan::REJECTED
    ) do |bantuan|
      bantuan.bantuan_dana_non_beasiswa_id = SecureRandom.uuid
      bantuan.waktu_galang_dana = Time.now
      bantuan.judul_galang_dana = "Bantuan Bencana Alam"
      bantuan.deskripsi_galang_dana = "Bantuan untuk korban banjir"
      bantuan.dana_yang_dibutuhkan = 5_000_000
      bantuan.bukti_butuh_bantuan = "bukti.png"
      bantuan.kategori = "Bencana"
    end

    # Kirim pesan
    result = SendApprovalPengajuanDanaNonBeasiswa.new(bantuan_dana_non_beasiswa: bantuan_dana_non_beasiswa).call

    # Output di luar rescue
    if result[:success]
      puts "Pesan berhasil dikirim ke +6288905126629 pada #{Time.now.strftime('%Y-%m-%d %H:%M:%S %Z')}!"
    else
      puts "Gagal mengirim pesan: #{result[:error]}"
    end

    # Rollback biar ga nyimpan data
    raise ActiveRecord::Rollback
  rescue StandardError => e
    Rails.logger.error("[Skrip] Error: #{e.message}")
    raise ActiveRecord::Rollback
  end
end