require 'rails_helper'

require_relative '../../app/messages/send_approval_pengajuan_dana_non_beasiswa_notification'
require_relative '../../app/services/twilio_whatsapp_sender'
require_relative '../../app/utils/enums/status_pengajuan' # Tambah ini

RSpec.describe SendApprovalPengajuanDanaNonBeasiswa do
  describe "#call" do
    let(:penanggung_jawab) do
      PenanggungJawabNonBeasiswa.create!(
        nomor_induk: "PJ001",
        nama: "Romli",
        nomor_telepon: "+6288905126629"
      )
    end

    let(:bantuan_dana_non_beasiswa) do
      BantuanDanaNonBeasiswa.create!(
        bantuan_dana_non_beasiswa_id: SecureRandom.uuid,
        penanggung_jawab_non_beasiswa: penanggung_jawab,
        waktu_galang_dana: Time.now,
        judul_galang_dana: "Bantuan Bencana Alam",
        deskripsi_galang_dana: "Bantuan untuk korban banjir",
        dana_yang_dibutuhkan: 5_000_000,
        bukti_butuh_bantuan: "bukti.png",
        kategori: "Bencana",
        status_pengajuan: Enums::StatusPengajuan::APPROVED
      )
    end

    it "mengirim notifikasi WhatsApp ke penanggung jawab jika pengajuan diterima" do
      sender = instance_double(TwilioWhatsappSender)
      expect(TwilioWhatsappSender).to receive(:new).with(
        to: penanggung_jawab.nomor_telepon,
        body: a_string_including("Halo #{penanggung_jawab.nama}") & a_string_including("Diterima")
      ).and_return(sender)

      expect(sender).to receive(:call).and_return({ success: true })

      result = described_class.new(bantuan_dana_non_beasiswa: bantuan_dana_non_beasiswa).call
      expect(result[:success]).to eq(true)
    end

    it "mengirim notifikasi WhatsApp ke penanggung jawab jika pengajuan ditolak" do
    # PERBAIKAN: Gunakan REJECTED bukan DONE
    bantuan_dana_non_beasiswa.update(status_pengajuan: Enums::StatusPengajuan::REJECTED)
    
    sender = instance_double(TwilioWhatsappSender)
    expect(TwilioWhatsappSender).to receive(:new).with(
        to: penanggung_jawab.nomor_telepon,
        body: a_string_including("Halo #{penanggung_jawab.nama}") & a_string_including("Ditolak")
    ).and_return(sender)

    expect(sender).to receive(:call).and_return({ success: true })

    result = described_class.new(bantuan_dana_non_beasiswa: bantuan_dana_non_beasiswa).call
    expect(result[:success]).to eq(true)
    end

    it "mengirim notifikasi WhatsApp ke penanggung jawab jika pengajuan selesai" do
  bantuan_dana_non_beasiswa.update(status_pengajuan: Enums::StatusPengajuan::DONE)
  
  sender = instance_double(TwilioWhatsappSender)
  expect(TwilioWhatsappSender).to receive(:new).with(
    to: penanggung_jawab.nomor_telepon,
    body: a_string_including("Halo #{penanggung_jawab.nama}") & a_string_including("Selesai")
  ).and_return(sender)

  expect(sender).to receive(:call).and_return({ success: true })

  result = described_class.new(bantuan_dana_non_beasiswa: bantuan_dana_non_beasiswa).call
  expect(result[:success]).to eq(true)
end

    it "tidak mengirim notifikasi jika pengajuan belum diproses" do
      bantuan_dana_non_beasiswa.update(status_pengajuan: Enums::StatusPengajuan::NEW)
      expect(TwilioWhatsappSender).not_to receive(:new)
      result = described_class.new(bantuan_dana_non_beasiswa: bantuan_dana_non_beasiswa).call
      expect(result[:success]).to eq(false)
      expect(result[:error]).to eq("Proses seleksi belum selesai")
    end
  end
end