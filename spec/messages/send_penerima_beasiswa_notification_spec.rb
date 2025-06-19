require 'rails_helper'

RSpec.describe SendPenerimaBeasiswaNotification do
  describe '#call' do
    let(:mahasiswa) do
      Mahasiswa.create!(
        nim: '12345678',
        nama: 'Kayla',
        nomor_telepon: '+6285872060952'
      )
    end

    let(:penanggung_jawab) do
      PenanggungJawab.create!(
        role: "PJ001",
        nama: "Pak Romli",
        username: "romli_pj",
        password: "securepass123",
        nomor_telepon: "+6285872060959"
      )
    end

    let(:penggalangan) do
      PenggalanganDanaBeasiswa.create!(
        penggalangan_dana_beasiswa_id: 2,
        judul: 'Beasiswa Prestasi 2025',
        deskripsi: 'Diberikan kepada mahasiswa berprestasi',
        waktu_dimulai: Date.today,
        waktu_berakhir: Date.today + 1.month,
        kuota_beasiswa: 1,
        target_dana: 10000000,
        target_penerima: 1,
        status: Enums::StatusPenggalanganDanaBeasiswa::DONE,
        total_nominal_terkumpul: 0,
        penanggung_jawab: penanggung_jawab
      )
    end

    let!(:donasi1) do
      Donasi.create!( 
        penggalangan_dana_beasiswa: penggalangan,
        donatur: Donatur.create!(
          nama: 'Donatur 1',
          nomor_telepon: '+6281111111111',
          password: 'password123',
          status: 1
        ),
        nominal_donasi: 5000000,
        status: Enums::StatusDonasi::APPROVED,
        nomor_referensi: "REF123456",
        waktu_berakhir: Date.today + 1.month
      )
    end

    let(:bantuan) do
      BantuanDanaBeasiswa.create!(
        bantuan_dana_beasiswa_id: 'BD123XYZ',
        mahasiswa: mahasiswa,
        penggalangan_dana_beasiswa: penggalangan,
        alasan_butuh_bantuan: 'Orang tua tidak mampu',
        golongan_ukt: 'III',
        kuitansi_pembayaran_ukt: 'kuitansi.pdf',
        gaji_orang_tua: 1000000,
        bukti_slip_gaji_orang_tua: 'slip.pdf',
        esai: 'Saya butuh beasiswa...',
        jumlah_tanggungan_keluarga: 4,
        biaya_transportasi: 200000,
        biaya_konsumsi: 300000,
        biaya_internet: 150000,
        total_pengeluaran_keluarga: 2000000,
        status_pengajuan: Enums::StatusPengajuan::DONE
      )
    end

    it 'mengirimkan pesan WhatsApp ke mahasiswa' do
      result = described_class.new(bantuan).call

      expect(result[:success]).to be(true)
    end
  end
end
