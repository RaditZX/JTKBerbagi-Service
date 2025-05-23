# messages/whatsapp_messages.rb
require_relative 'beasiswa_messages'
require_relative 'non_beasiswa_messages'
require_relative 'donasi_messages'
require_relative 'penggalangan_dana_messages'

module WhatsappMessages
  include BeasiswaMessages
  include NonBeasiswaMessages
  include DonasiMessages
  include PenggalanganDanaMessages
end
