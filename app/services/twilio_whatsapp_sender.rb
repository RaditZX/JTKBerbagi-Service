require 'twilio-ruby'

class TwilioWhatsappSender
  def initialize(to:, body:)
    @to = normalize_phone_number(to)
    @body = body
  end

  def call
    account_sid = ENV['TWILIO_ACCOUNT_SID']
    auth_token = ENV['TWILIO_AUTH_TOKEN']
    
    raise "TWILIO_ACCOUNT_SID tidak diset di environment" if account_sid.nil? || account_sid.empty?
    raise "TWILIO_AUTH_TOKEN tidak diset di environment" if auth_token.nil? || auth_token.empty?

    @client = Twilio::REST::Client.new(account_sid, auth_token)

    message = @client.messages.create(
      from: 'whatsapp:+14155238886',
      to: "whatsapp:#{@to}",
      body: @body,
      status_callback: 'https://your-app.com/twilio/status_callback'
    )
    
    { success: true, message_sid: message.sid }
  rescue StandardError => e
    Rails.logger.error("[Twilio] Error: #{e.message}")
    { success: false, error: e.message }
  end

  private

  def normalize_phone_number(number)
    return number if number.nil? || number.empty?
    
    number = number.gsub(/[^0-9+]/, '')
    
    if number.start_with?('0')
      number = "+62#{number[1..-1]}"
    elsif !number.start_with?('+')
      number = "+62#{number}"
    end
    
    number
  end
end