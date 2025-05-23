class MidtransService
  def self.handle_notification(notification_params)
    return false unless verify_notification(notification_params)

    # ambil data dari notifikasi berdasarkan order_id
    order_id = notification_params['order_id']
    transaction_status = notification_params['transaction_status']
    fraud_status = notification_params['fraud_status']

    donasi = Donasi.find_by(nomor_referensi: order_id)
    return false unless donasi

    donasi.validate_payment_status(transaction_status)

    case transaction_status
    when 'settlement'
      # update total donasi jika status settlement
      update_fundraising_total(donasi)
    when 'expire', 'cancel'
      send_expiration_notification(donasi)
    end

    true
  end

  private
  
  # log jika donasi kadaluarsa (24 jam)
  def self.send_expiration_notification(donasi)
    Rails.logger.info "Donation #{donasi.nomor_referensi} has expired"
  end

    def self.update_fundraising_total(donasi)
    fundraising = donasi.penggalangan_dana_beasiswa || donasi.bantuan_dana_non_beasiswa
    return unless fundraising

    fundraising.update(
      total_nominal_terkumpul: fundraising.total_nominal_terkumpul + donasi.nominal_donasi
    )
  end
end
