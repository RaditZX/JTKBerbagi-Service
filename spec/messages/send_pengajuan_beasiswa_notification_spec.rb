require 'rails_helper'

RSpec.describe SendPengajuanBeasiswaNotification do
  let(:mahasiswa) do
    Mahasiswa.create!(
      nim: '12345678',
      nama: 'Budi Mahasiswa',
      nomor_telepon: '+6285872060952'
    )
  end

  let(:penanggung_jawab) do
    PenanggungJawab.create!(
      nama: "Pak Ketua",
      role: "pj_jtk_berbagi",
      username: "pak.ketua",
      password: "passwordku",
      nomor_telepon: "+628123456789"
    )
  end

  let(:penggalangan_dana) do
      PenggalanganDanaBeasiswa.create!(
        penggalangan_dana_beasiswa_id: 2,
        penanggung_jawab: penanggung_jawab,
        deskripsi: 'Test',
        judul: 'Test Beasiswa',
        waktu_dimulai: Date.today,
        waktu_berakhir: Date.today + 1.month,
        kuota_beasiswa: 10,
        target_dana: 10_000_000,
        target_penerima: 10,
        total_nominal_terkumpul: 0,
        status: 1
      )
    end


  let(:bantuan_dana) do
    BantuanDanaBeasiswa.create!(
      bantuan_dana_beasiswa_id: 'BD123XYZ',
      penggalangan_dana_beasiswa: penggalangan_dana,
      mahasiswa: mahasiswa,
      status_pengajuan: Enums::StatusPengajuan::NEW,
      alasan_butuh_bantuan: "Tidak mampu",
      golongan_ukt: 3,
      kuitansi_pembayaran_ukt: "kuitansi123.pdf",
      gaji_orang_tua: 2500000,
      bukti_slip_gaji_orang_tua: "slip_gaji123.pdf",
      esai: "Saya butuh beasiswa untuk melanjutkan studi.",
      jumlah_tanggungan_keluarga: 4,
      biaya_transportasi: 500000,
      biaya_konsumsi: 1000000,
      biaya_internet: 200000,
      total_pengeluaran_keluarga: 3700000
    )
  end

  it 'mengirim notifikasi WhatsApp saat pengajuan beasiswa berhasil diajukan' do
    whatsapp_sender_instance = instance_double(TwilioWhatsappSender, call: true)

    expect(TwilioWhatsappSender).to receive(:new).with(
      to: mahasiswa.nomor_telepon,
      body: a_string_matching(/Pengajuan Bantuan Dana Beasiswa Anda berhasil didaftarkan/i)
    ).and_return(whatsapp_sender_instance)

    expect(whatsapp_sender_instance).to receive(:call)

    # Jalankan notifikasi
    described_class.new(mahasiswa: mahasiswa, bantuan_dana: bantuan_dana, penggalangan_dana: penggalangan_dana).call
  end

  it 'mengirim notifikasi WhatsApp saat pengajuan beasiswa beneran berhasil diajukan' do
  # Jangan pakai instance_double atau expect untuk TwilioWhatsappSender

  # Jalankan notifikasi sesungguhnya, akan kirim pesan WhatsApp beneran
  result = described_class.new(mahasiswa: mahasiswa, bantuan_dana: bantuan_dana, penggalangan_dana: penggalangan_dana).call

  # Kamu bisa cek apakah hasilnya success atau error
  expect(result[:success]).to eq(true)
end


end
