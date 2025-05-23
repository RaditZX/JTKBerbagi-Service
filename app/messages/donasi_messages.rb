# messages/donasi_messages.rb
module DonasiMessages
  module_function

  def donasi_diterima(donatur_name, nominal)
    "Terima kasih #{donatur_name} atas donasi sebesar Rp#{nominal.to_s(:delimited)}. Donasi kamu sangat berarti bagi penerima bantuan."
  end

  def donasi_kedaluwarsa(donatur_name)
    "Halo #{donatur_name}, kami ingin menginformasikan bahwa sesi donasi kamu telah kedaluwarsa. Silakan lakukan donasi kembali jika masih berminat membantu."
  end
end
