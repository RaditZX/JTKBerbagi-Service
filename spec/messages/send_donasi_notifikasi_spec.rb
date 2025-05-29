require 'rails_helper'


RSpec.describe NotifikasiDonasiService, type: :service do
  let(:penanggung_jawab) do
    PenanggungJawab.create!(
      nama: 'Admin Beasiswa',
      role: Enums::RolePenanggungJawab::PIHAK_JURUSAN, # Menggunakan 1 berdasarkan seeder
      username: 'admin_b',
      password: 'password123',
      nomor_telepon: '081122334455'
    )
  end
  let(:donatur) do
    Donatur.create!(
      nama: 'Budi',
      nomor_telepon: '085872060952', # Menjadi +6285872060952 setelah normalisasi
      password: 'password123',
      status: 1 # Untuk scope donatur_registered
    )
  end
  let(:galang_beasiswa) do
    PenggalanganDanaBeasiswa.create!(
      penggalangan_dana_beasiswa_id: 1, # Menambahkan ID eksplisit
      judul: 'Beasiswa Peduli Pendidikan 2025',
      deskripsi: 'Bantuan dana UKT untuk mahasiswa terdampak ekonomi',
      target_dana: 200_000_000,
      target_penerima: 100,
      penanggung_jawab: penanggung_jawab,
      status: 1, # Menggunakan 1 berdasarkan seeder (ONGOING)
      waktu_dimulai: Date.new(2025, 5, 1), # Dari seeder
      waktu_berakhir: Date.new(2025, 8, 31), # Dari seeder
      kuota_beasiswa: 100, # Dari seeder
      total_nominal_terkumpul: 0 # Default
    )
  end

  context 'ketika status NEW' do
    it 'mengirim notifikasi WA' do
      donasi = Donasi.create!(
        nomor_referensi: 'REF001',
        nominal_donasi: 100_000,
        status: Enums::StatusDonasi::NEW, # Menggunakan 0
        penggalangan_dana_beasiswa: galang_beasiswa,
        donatur: donatur,
        waktu_berakhir: Time.now + 1.month # Dari seeder
      )
      expect { NotifikasiDonasiService.kirim_notifikasi(donasi) }
        .to output(/Kirim ke \+6285872060952/).to_stdout
      expect(NotifikasiDonasiService.kirim_notifikasi(donasi)).to include(success: true)
    end
  end

  context 'ketika status EXPIRED' do
    it 'mengirim notifikasi WA' do
      donasi = Donasi.create!(
        nomor_referensi: 'REF002',
        nominal_donasi: 150_000,
        status: Enums::StatusDonasi::EXPIRED, # Menggunakan 4
        penggalangan_dana_beasiswa: galang_beasiswa,
        donatur: donatur,
        waktu_berakhir: Time.now + 1.month # Dari seeder
      )
      expect { NotifikasiDonasiService.kirim_notifikasi(donasi) }
        .to output(/Kirim ke \+6285872060952/).to_stdout
      expect(NotifikasiDonasiService.kirim_notifikasi(donasi)).to include(success: true)
    end
  end

  context 'ketika status APPROVED' do
    it 'mengirim notifikasi WA' do
      donasi = Donasi.create!(
        nomor_referensi: 'REF003',
        nominal_donasi: 200_000,
        status: Enums::StatusDonasi::APPROVED, # Menggunakan 1
        penggalangan_dana_beasiswa: galang_beasiswa,
        donatur: donatur,
        waktu_berakhir: Time.now + 1.month # Dari seeder
      )
      expect { NotifikasiDonasiService.kirim_notifikasi(donasi) }
        .to output(/Kirim ke \+6285872060952/).to_stdout
      expect(NotifikasiDonasiService.kirim_notifikasi(donasi)).to include(success: true)
    end
  end
end