# messages/penggalangan_dana_messages.rb
module PenggalanganDanaMessages
  module_function

  def penggalangan_dana_selesai(penanggung_jawab_name, judul)
    "Halo #{penanggung_jawab_name}, penggalangan dana dengan judul '#{judul}' telah selesai. Silakan cek laporan rekapitulasi."
  end
end
