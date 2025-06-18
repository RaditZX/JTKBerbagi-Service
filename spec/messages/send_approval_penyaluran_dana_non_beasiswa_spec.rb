require 'rails_helper'

RSpec.describe SendApprovalPenyaluranDanaNonBeasiswa do
  describe "#call" do
    let(:penanggung_jawab) do
      PenanggungJawabNonBeasiswa.create!(
        nomor_induk: "PJ001",
        nama: "Romli",
        nomor_telepon: "+6288905126629"
      )
    end

    let(:bantuan_dana) do
      BantuanDanaNonBeasiswa.create!(
        bantuan_dana_non_beasiswa_id: SecureRandom.uuid,
        penanggung_jawab_non_beasiswa: penanggung_jawab,
        waktu_galang_dana: Time.now,
        judul_galang_dana: "Bantuan Bencana Alam",
        deskripsi_galang_dana: "Bantuan untuk korban banjir",
        dana_yang_dibutuhkan: 5000000,
        bukti_butuh_bantuan: "bukti.png",
        kategori: "Bencana",
        status_pengajuan: Enums::StatusPengajuan::DONE,
        status_penyaluran: Enums::StatusPenyaluran::DELIVERED
      )
    end

    it "mengirim notifikasi WhatsApp ke penanggung jawab jika penyaluran berhasil" do
      sender = instance_double(TwilioWhatsappSender)
      expect(TwilioWhatsappSender).to receive(:new).with(
        to: penanggung_jawab.nomor_telepon,
        body: a_string_including("Halo #{penanggung_jawab.nama}")
      ).and_return(sender)

      expect(sender).to receive(:call)

      result = described_class.new(bantuan_dana: bantuan_dana).call
      expect(result[:success]).to eq(true)
    end
  end
end
