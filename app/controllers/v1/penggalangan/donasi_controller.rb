class V1::Penggalangan::DonasiController < ApplicationController
    # before_action :

  def createDonasi
    if params[:id].blank?
      return render_error_response("Id tidak boleh kosong!")
    end
    penggalangan_dana_beasiswa = PenggalanganDanaBeasiswa.where(penggalangan_dana_beasiswa_id: params[:id]).first
    penggalangan_dana_non_beasiswa = BantuanDanaNonBeasiswa.pengajuan_approved.where(bantuan_dana_non_beasiswa_id: params[:id]).first

    if !penggalangan_dana_beasiswa.present? and !penggalangan_dana_non_beasiswa.present?
      return render_error_response("id Penggalangan Dana tidak dapat ditemukan!")
    end

    donasi_not_completed = Donasi.new_donation.where(donatur_id: params[:nomor_telepon])
    is_struk_pembayaran = 1
    if donasi_not_completed.present?
      donasi_not_completed each do |data|
        if data.struk_pembayaran == nil
          is_struk_pembayaran = 0
        end
      end
    end
    if is_struk_pembayaran == 0
      return render_error_response("Lakukan upload struk pembayaran pada donasi sebelumnya!")
    end

    donatur_registered = Donatur.where(nomor_telepon: params[:nomor_telepon]).first
    if donatur_registered.present?
      donatur = donatur_registered
    else
      donatur = Donatur.new({
        nama: params[:nama],
        nomor_telepon: params[:nomor_telepon],
        status: Enums::StatusDonatur::CANDIDATE
      })
    end

    rekening_bank_owned = RekeningBank.where(nomor_rekening: params[:nomor_rekening]).first
    rekening_bank_registered = RekeningBank.where(donatur_id: params[:nomor_telepon]).first
    if rekening_bank_registered.present?
      rekening_bank = rekening_bank_registered
    elsif rekening_bank_owned.present?
      return render_error_response("Nomor Rekening sudah terdaftar!")
    else
      rekening_bank = RekeningBank.new(rekening_bank_params)
      rekening_bank.assign_attributes({
        donatur: donatur
      })
    end
    donatur.save(:validate => false)

    donasi = Donasi.new(donasi_params)
    waktu_berakhir = DateTime.now + 1.hour
    donasi.assign_attributes({
      nomor_referensi: generate_unique_nomor_referensi(),
      waktu_berakhir: waktu_berakhir,
      status: Enums::StatusDonasi::NEW,
      donatur: donatur
    })

    if penggalangan_dana_beasiswa.present?
      donasi.assign_attributes(penggalangan_dana_beasiswa_id: penggalangan_dana_beasiswa.penggalangan_dana_beasiswa_id)
    else
      donasi.assign_attributes(bantuan_dana_non_beasiswa_id: penggalangan_dana_non_beasiswa.bantuan_dana_non_beasiswa_id)
    end

    if donasi.save && rekening_bank.save
      render_success_response(Constants::RESPONSE_CREATED, {donasi: donasi, donatur: donatur, rekening_bank: rekening_bank}, Constants::STATUS_OK)
    else
      render_error_response({donasi: donasi.errors.full_messages, donatur: donatur.errors.full_messages, rekening_bank: rekening_bank.errors.full_messages})
    end
  end

  def getPendingDonasi
    donasi = Donasi.new_donation.where(nomor_referensi: params[:nomor_referensi]).first
    return render_error_response("Data Donasi baru tidak ditemukan!") unless donasi
  
    status_donasi, durasi, waktu_berakhir = calculate_donasi_status_and_duration(donasi)
    
    render_success_response(Constants::RESPONSE_SUCCESS,{
      durasi: durasi, 
      waktu_berakhir: waktu_berakhir,
      status: status_donasi,
      jumlah_donasi: donasi.nominal_donasi,
      rekening_bank: V1::User::PenanggungJawabController.new.getRekeningBankByPenanggungJawab
      },
      Constants::STATUS_OK
    )
  end

  def uploadStrukPembayaran
    donasi = Donasi.new_donation.where(nomor_referensi: params[:nomor_referensi]).first
    return render_error_response("Data Donasi baru tidak ditemukan!") unless donasi
  
    if params[:struk_pembayaran].blank?
      return render_error_response("Path struk pembayaran tidak boleh kosong!")
    end
  
    donasi.update(struk_pembayaran: params[:struk_pembayaran])
    
    render_success_response(Constants::RESPONSE_SUCCESS,donasi, Constants::STATUS_CREATED)
  end
  
  def approvalExpiredDonasi(nomor_referensi, is_approve)
    expired_donation = Donasi.expired.where(nomor_referensi: nomor_referensi).first
    donatur = Donatur.where(nomor_telepon: expired_donation.donatur_id).first
    penggalangan_dana_beasiswa = PenggalanganDanaBeasiswa.on_going.where(penggalangan_dana_beasiswa_id: expired_donation.penggalangan_dana_beasiswa_id).first
    penggalangan_dana_non_beasiswa = BantuanDanaNonBeasiswa.where(bantuan_dana_non_beasiswa_id: expired_donation.bantuan_dana_non_beasiswa_id).first
    if is_approve == "true"
      if penggalangan_dana_beasiswa.present?
        donasi_approved = Donasi.approved.where(penggalangan_dana_beasiswa_id: penggalangan_dana_beasiswa.penggalangan_dana_beasiswa_id)
        total_nominal_awal = donasi_approved.present? ? donasi_approved.pluck(:nominal_donasi).inject(0, :+) : 0
        total_nominal_terkumpul = total_nominal_awal + new_donation.nominal_donasi
        penggalangan_dana_beasiswa.update(total_nominal_terkumpul: total_nominal_terkumpul)
      else
        donasi_approved = Donasi.approved.where(bantuan_dana_non_beasiswa_id: penggalangan_dana_non_beasiswa.bantuan_dana_non_beasiswa_id)
        total_nominal_awal = donasi_approved.present? ? donasi_approved.pluck(:nominal_donasi).inject(0, :+) : 0
        total_nominal_terkumpul = total_nominal_awal + new_donation.nominal_donasi
        penggalangan_dana_non_beasiswa.update(total_nominal_terkumpul: total_nominal_terkumpul)
      end
  
      if donatur.status == 0
        password_candidate = (0...8).map { (65 + rand(26)).chr }.join
        donatur.update(
          password: password_candidate,
          password_confirmation: password_candidate,
          status: Enums::StatusDonatur::REGISTERED,
        )
      else
        password_candidate = []
      end
      expired_donation.update({status: Enums::StatusDonasi::APPROVED, tanggal_approve: DateTime.now})  
    else
      expired_donation.update(status: Enums::StatusDonasi::REJECTED, tanggal_approve: DateTime.now)
    end
    return [expired_donation, penggalangan_dana_beasiswa.present? ? penggalangan_dana_beasiswa : penggalangan_dana_non_beasiswa, donatur, password_candidate]
  end

  def approvalNewDonasi(nomor_referensi, is_approve)
    new_donation = Donasi.new_donation.where(nomor_referensi: nomor_referensi).first
    donatur = Donatur.where(nomor_telepon: new_donation.donatur_id).first
    penggalangan_dana_beasiswa = PenggalanganDanaBeasiswa.on_going.where(penggalangan_dana_beasiswa_id: new_donation.penggalangan_dana_beasiswa_id).first
    penggalangan_dana_non_beasiswa = BantuanDanaNonBeasiswa.where(bantuan_dana_non_beasiswa_id: new_donation.bantuan_dana_non_beasiswa_id).first
    if is_approve == "true"
      if penggalangan_dana_beasiswa.present?
        donasi_approved = Donasi.approved.where(penggalangan_dana_beasiswa_id: penggalangan_dana_beasiswa.penggalangan_dana_beasiswa_id)
        total_nominal_awal = donasi_approved.present? ? donasi_approved.pluck(:nominal_donasi).inject(0, :+) : 0
        total_nominal_terkumpul = total_nominal_awal + new_donation.nominal_donasi
        penggalangan_dana_beasiswa.update(total_nominal_terkumpul: total_nominal_terkumpul)
      else
        donasi_approved = Donasi.approved.where(bantuan_dana_non_beasiswa_id: penggalangan_dana_non_beasiswa.bantuan_dana_non_beasiswa_id)
        total_nominal_awal = donasi_approved.present? ? donasi_approved.pluck(:nominal_donasi).inject(0, :+) : 0
        total_nominal_terkumpul = total_nominal_awal + new_donation.nominal_donasi
        penggalangan_dana_non_beasiswa.update(total_nominal_terkumpul: total_nominal_terkumpul)
      end

      if donatur.status == 0
        password_candidate = (0...8).map { (65 + rand(26)).chr }.join
        donatur.update(
          password: password_candidate,
          password_confirmation: password_candidate,
          status: Enums::StatusDonatur::REGISTERED,
        )
      else
        password_candidate = []
      end
      new_donation.update(status: Enums::StatusDonasi::APPROVED, tanggal_approve: DateTime.now)  
    else
      new_donation.update(status: Enums::StatusDonasi::REJECTED, tanggal_approve: DateTime.now)
    end
    return [new_donation, penggalangan_dana_beasiswa.present? ? penggalangan_dana_beasiswa : penggalangan_dana_non_beasiswa, donatur, password_candidate]
  end

  def approvalDonasi
    if params[:nomor_referensi].blank?
      return render_error_response("Nomor Referensi tidak boleh kosong!")
    end

    new_donation = Donasi.new_donation.where(nomor_referensi: params[:nomor_referensi]).first
    expired_donation = Donasi.expired.where(nomor_referensi: params[:nomor_referensi]).first

    if !new_donation.present? && !expired_donation.present?
      return render_error_response("Nomor Referensi Donasi tidak dapat ditemukan")
    end
  
    if params[:is_approve].blank? || !["true", "false"].include?(params[:is_approve])
      return render_error_response("is_approve hanya dapat true atau false!")
    end
    
    if params[:is_approve] == "true"
      if new_donation.present?
        donasi_baru, penggalangan_dana, donatur, password_candidate = approvalNewDonasi(params[:nomor_referensi], params[:is_approve])
      else
        donasi_expired, penggalangan_dana, donatur, password_candidate = approvalExpiredDonasi(params[:nomor_referensi], params[:is_approve])
      end
    else
      if new_donation.present?
        donasi_baru, penggalangan_dana, donatur, password_candidate = approvalNewDonasi(params[:nomor_referensi], params[:is_approve])
      else
        donasi_expired, penggalangan_dana, donatur, password_candidate = approvalExpiredDonasi(params[:nomor_referensi], params[:is_approve])
      end
    end
    
    return render_success_response(Constants::RESPONSE_SUCCESS, {donasi: donasi_baru.present? ? donasi_baru : donasi_expired, penggalangan_dana: penggalangan_dana, donatur: donatur, password_donatur: password_candidate}, Constants::STATUS_OK)
  end

  def getDonasiByStatus
    status = params[:status].to_i
  
    if status.zero? || status == 4
      status_donasi = status.zero? ? "Baru" : "Expired"
      donasi = Donasi.where(status: status)
      if status.zero? and donasi.present?
        array_of_donasi = []
        donasi.each do |data|
          if data.struk_pembayaran.present?
            donatur = Donatur.where(nomor_telepon: data.donatur_id).first
            rekening_bank = RekeningBank.where(donatur_id: donatur.nomor_telepon).first
            array_of_donasi << data.attributes.merge({
              judul_galang_dana: PenggalanganDanaBeasiswa.on_going.where(penggalangan_dana_beasiswa_id: data.penggalangan_dana_beasiswa_id).present? ? PenggalanganDanaBeasiswa.on_going.where(penggalangan_dana_beasiswa_id: data.penggalangan_dana_beasiswa_id).first.judul : BantuanDanaNonBeasiswa.where(bantuan_dana_non_beasiswa_id: data.bantuan_dana_non_beasiswa_id).first.judul_galang_dana,
              donatur: donatur,
              rekening_bank: rekening_bank
            })
          end
        end
        array_of_donasi = array_of_donasi.length > 1 ? array_of_donasi.reverse : array_of_donasi
      elsif status == 4 and donasi.present?
        donasi.each do |data|
          judul_galang_dana_beasiswa = PenggalanganDanaBeasiswa.on_going.where(penggalangan_dana_beasiswa_id: data.penggalangan_dana_beasiswa_id).first.judul
            donatur = Donatur.where(nomor_telepon: data.donatur_id).first
            rekening_bank = RekeningBank.where(donatur_id: donatur.nomor_telepon).first
            array_of_donasi << data.attributes.merge({
              judul_galang_dana: judul_galang_dana_beasiswa.present? ? judul_galang_dana_beasiswa : 
              BantuanDanaNonBeasiswa.pengajuan_approved.where(bantuan_dana_non_beasiswa_id: data.bantuan_dana_non_beasiswa_id).first.judul_galang_dana,
              donatur: donatur,
              rekening_bank: rekening_bank
            })
        end
        array_of_donasi = array_of_donasi.length > 1 ? array_of_donasi.reverse : array_of_donasi
      else
        return render_error_response("Tidak ada data donasi #{status_donasi}!")
      end
      render_success_response(Constants::RESPONSE_SUCCESS, array_of_donasi, Constants::STATUS_OK)
    else
      render_error_response("Status #{status} tidak ada!, status hanya dapat 0 atau 4!")
    end
  end

  def getTotalNewDonasi
    donasi = Donasi.new_donation
    if not donasi.present?
      render json: {
        response_code: Constants::RESPONSE_SUCCESS, 
        response_message: "Success", 
        data: 0
        }, status: :ok
    else
      render json: {
        response_code: Constants::RESPONSE_SUCCESS, 
        response_message: "Success", 
        data: donasi.length
        }, status: :ok
    end
  end

  def getTotalAllDonasi
    donasi = Donasi.approved
    array_of_nominal_donasi = []
    array_of_nominal_penyaluran = []
    donasi.each do |data|
      if data.penggalangan_dana_beasiswa_id != nil
        bantuan_dana_beasiswa = BantuanDanaBeasiswa.where.not(status_pengajuan: Enums::StatusPengajuan::NEW).where(penggalangan_dana_beasiswa_id: data.penggalangan_dana_beasiswa_id).first
        if bantuan_dana_beasiswa.present?
          if bantuan_dana_beasiswa.nominal_penyaluran != nil
            array_of_nominal_penyaluran << bantuan_dana_beasiswa.nominal_penyaluran
          end
        end
      end
      array_of_nominal_donasi << data.nominal_donasi
    end
    if array_of_nominal_penyaluran.present?
      total_nominal_penyaluran = array_of_nominal_penyaluran.sum.sum
    else
      total_nominal_penyaluran = array_of_nominal_penyaluran.sum
    end
    total_donasi = array_of_nominal_donasi.sum - total_nominal_penyaluran
    render_success_response(Constants::RESPONSE_SUCCESS, total_donasi, Constants::STATUS_OK)
  end

  def search
    donasi = Penggalangan::Donasi.all
    if params[:keyword].blank?
      render json: {
        response_code: Constants::ERROR_CODE_VALIDATION,
        response_message: "Nomor Referensi tidak boleh kosong!"
        }, status: :unprocessable_entity
    elsif not donasi.present?
      render json: {
        response_code: Constants::ERROR_CODE_VALIDATION,
        response_message: "Tidak ada data donasi!"
        }, status: :unprocessable_entity
    else
      searched_donasi = donasi.select do | data | data.attributes.values.grep(/^#{params[:keyword]}/i).any? end
      if not donasi.present?
        render json: {
          response_code: Constants::ERROR_CODE_VALIDATION,
          response_message: "Tidak ada data donasi berdasarkan keyword: #{params[:keyword]}!"
          }, status: :unprocessable_entity
      else
        penggalangan_dana = Penggalangan::PenggalanganDana.where(:donasi_id.in => searched_donasi.pluck(:id))
        donatur = User::Donatur.where(:donasi_id.in => searched_donasi.pluck(:id))
        if searched_donasi.length > 1
          array_of_data_donasi = []
          searched_donasi.each_with_index do |data_donation, index_donasi|
            penggalangan_dana = Penggalangan::PenggalanganDana.where(:donasi_id => data_donation.id).first
            donatur = User::Donatur.where(:donasi_id => data_donation.id).first
            if penggalangan_dana.pengajuan_bantuan_id.kind_of?(Array)
              pengajuan_bantuan = Pengajuan::PengajuanBantuan.penggalangan_dana.where(:id => penggalangan_dana.pengajuan_bantuan_id[0])
            else
              pengajuan_bantuan = Pengajuan::PengajuanBantuan.penggalangan_dana.where(:id => penggalangan_dana.pengajuan_bantuan_id)
            end
            object_data_donasi = penggalangan_dana.attributes.merge({
              :pengajuan_bantuan_id => pengajuan_bantuan.first,
              :donasi_id => donatur.attributes.merge(:donasi_id => data_donation)
            })
            object_data_donasi["donatur"] = object_data_donasi.delete("donasi_id")
            array_of_data_donasi << object_data_donasi
  
          end
          data_donasi = array_of_data_donasi.reverse
        else
          data_penggalangan_dana = penggalangan_dana.first
          if data_penggalangan_dana.pengajuan_bantuan_id.kind_of?(Array)
            pengajuan_bantuan = Pengajuan::PengajuanBantuan.penggalangan_dana.where(:id => penggalangan_dana.first.pengajuan_bantuan_id[0])
          else
            pengajuan_bantuan = Pengajuan::PengajuanBantuan.penggalangan_dana.where(:id => penggalangan_dana.first.pengajuan_bantuan_id)
          end
          bank = Bank.where(:id => donatur.first.bank_id).first
          data_donasi = data_penggalangan_dana.attributes.merge({
            :pengajuan_bantuan_id => pengajuan_bantuan.first,
            :donasi_id => donatur.first.attributes.merge({
              :donasi_id => searched_donasi.first,
              :bank_id => bank
              })
          })
          data_donasi["donatur"] = data_donasi.delete("donasi_id")
        end
        render json: {
          response_code: Constants::RESPONSE_SUCCESS, 
          response_message: "Success", 
          data: data_donasi
          }, status: :ok
      end
    end
  end

  private
  # Form Donasi
  def donasi_params
    params.permit(
      :nominal_donasi,
    )
  end

  def rekening_bank_params
    params.permit(:nama_bank, :nomor_rekening, :nama_pemilik_rekening)
  end

  def fetch_pengajuan_bantuan(pengajuan_bantuan_id)
    if pengajuan_bantuan_id.kind_of?(Array)
      Pengajuan::PengajuanBantuan.pengajuan_baru_admin.where(id: pengajuan_bantuan_id[0]).first
    else
      pengajuan_bantuan = Pengajuan::PengajuanBantuan.where(id: pengajuan_bantuan_id).first
      pengajuan_bantuan.jenis == "Beasiswa" ? Pengajuan::PengajuanBantuan.pengajuan_baru_admin.where(id: pengajuan_bantuan_id).first : pengajuan_bantuan
    end
  end
  
  def prepare_donatur_and_check_struk(data_donatur, pengajuan_bantuan)
    is_struk_pembayaran = 0
    if data_donatur.present?
      donatur = data_donatur
      donasi_donatur = Donasi.new_donation.where(donatur_id: data_donatur.nomor_telepon)
      if donasi_donatur.length > 1 && donasi_donatur.pluck(:struk_pembayaran).length > 1
        is_struk_pembayaran = 1
      end
    else
      donatur = Donatur.new(
        bank: bank,
        nama: params[:nama],
        nomor_telepon: params[:nomor_telepon],
        status: Enums::StatusDonatur::CANDIDATE
      )
      rekening_bank_owned = RekeningBank.where(nomor_rekening: params[:nomor_rekening]).first
      rekening_bank_registered = RekeningBank.where(donatur_id: params[:nomor_telepon]).first
      if rekening_bank_registered.present?
        rekening_bank = rekening_bank_registered
      elsif rekening_bank_owned.present?
        return render_error_response("Nomor Rekening sudah terdaftar!")
      else
        rekening_bank = RekeningBank.new(rekening_bank_params)
        rekening_bank.assign_attributes({
          donatur: donatur
        })
      end
      rekening_bank.save
      donatur.save(:validate => false)
      is_struk_pembayaran = 0
    end
    [donatur, is_struk_pembayaran]
  end
  
  def generate_unique_nomor_referensi
    random_number = 6.times.map { 10 + Random.rand(11) }.join("")
    while Donasi.where(nomor_referensi: random_number).exists?
      random_number = 6.times.map { 10 + Random.rand(11) }.join("")
    end
    return random_number
  end
  
  def randomize_dokumen_sertifikat_id
    begin
      return dokumen_sertifikat_id = SecureRandom.random_number(1_000_000)
    end while DokumenSertifikat.where(dokumen_sertifikat_id: dokumen_sertifikat_id).exists?
  end

  def calculate_donasi_status_and_duration(donasi)
    seconds_diff = (donasi.waktu_berakhir - DateTime.now).to_i.abs
  
    if not donasi.struk_pembayaran.present?
      status_donasi = Enums::StatusDonasi::NEW
      if seconds_diff < 1
        donasi.update(status: Enums::StatusDonasi::EXPIRED)
      end
    else
      status_donasi = Enums::StatusDonasi::DONE
    end
  
    hours = seconds_diff / 3600
    seconds_diff -= hours * 3600
    minutes = seconds_diff / 60
    seconds_diff -= minutes * 60
    seconds = seconds_diff
  
    durasi = "#{hours.to_s.rjust(2, '0')}:#{minutes.to_s.rjust(2, '0')}:#{seconds.to_s.rjust(2, '0')}"
    waktu_berakhir = donasi.waktu_berakhir.strftime("%A, %d %B %Y %H:%M")
  
    [status_donasi, durasi, waktu_berakhir]
  end
end
