require 'twilio-ruby'

class TwilioWhatsappSender
  def initialize(to:, body:)
    @to = normalize_phone_number(to)
    @body = body
  end

  def call
    puts "Kirim ke #{@to}" # Tambahkan log ke stdout
    account_sid = ENV['TWILIO_ACCOUNT_SID']
    auth_token = ENV['TWILIO_AUTH_TOKEN']
    
    @client = Twilio::REST::Client.new(account_sid, auth_token)

    message = @client.messages.create(
      from: 'whatsapp:+14155238886',
      to: "whatsapp:#{@to}",
      body: @body,
      status_callback: 'https://your-app.com/twilio/status_callback'
    )
    { success: true, message_sid: message.sid }
  rescue StandardError => e
    { success: false, error: e.message }
  end

  private

  def normalize_phone_number(number)
    number = number.gsub(/[^0-9+]/, '')
    
    # Jika nomor dimulai dengan 0, ganti dengan +62
    if number.start_with?('0')
      number = "+62#{number[1..-1]}"
    elsif !number.start_with?('+')
      number = "+62#{number}"
    end
    number
  end
end