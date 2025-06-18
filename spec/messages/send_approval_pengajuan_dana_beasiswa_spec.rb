require 'rails_helper'

require_relative '../../app/messages/send_approval_pengajuan_dana_beasiswa_notification'
require_relative '../../app/services/twilio_whatsapp_sender'

RSpec.describe SendApprovalPengajuanDanaBeasiswa do
  describe "#call" do
    let(:mahasiswa) do
      Mahasiswa.create!(
        nim: "12345678",
        nama: "Budi",
        nomor_telepon: "+6288905126629"
      )
    end

    let(:penanggung_jawab) do
      PenanggungJawab.create!(
        nama: "Pak Andi",
        role: Enums::RolePenanggungJawab::JTK_BERBAGI,
        username: "andi_jtk",
        password: "password123",
        nomor_telepon: "+6281234567890"
      )
    end

    let(:penggalangan_dana_beasiswa) do
      PenggalanganDanaBeasiswa.create!(
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
    end

    let(:bantuan_dana_beasiswa) do
      BantuanDanaBeasiswa.create!(
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
        status_pengajuan: Enums::StatusPengajuan::APPROVED # Pastikan nilai ini ada
      )
    end

    it "mengirim notifikasi WhatsApp ke mahasiswa jika pengajuan diterima" do
      # Debugging: Periksa nilai status_pengajuan
      puts "Status pengajuan: #{bantuan_dana_beasiswa.status_pengajuan}"
      puts "Enums::StatusPengajuan::APPROVED: #{Enums::StatusPengajuan::APPROVED}"

      sender = instance_double(TwilioWhatsappSender)
      expect(TwilioWhatsappSender).to receive(:new).with(
        to: mahasiswa.nomor_telepon,
        body: a_string_including("Halo #{mahasiswa.nama}") & a_string_including("Diterima")
      ).and_return(sender)

      expect(sender).to receive(:call).and_return({ success: true })

      result = described_class.new(bantuan_dana_beasiswa: bantuan_dana_beasiswa).call

      if result[:success] == false
        puts "Error dari Twilio: #{result[:error]}"
      end

      expect(result[:success]).to eq(true)
    end

    it "tidak mengirim notifikasi jika pengajuan belum diproses" do
      bantuan_dana_beasiswa.update(status_pengajuan: Enums::StatusPengajuan::NEW)
      expect(TwilioWhatsappSender).not_to receive(:new)
      result = described_class.new(bantuan_dana_beasiswa: bantuan_dana_beasiswa).call
      expect(result[:success]).to eq(false)
      expect(result[:error]).to eq("Proses seleksi belum selesai")
    end
  end
end