class V1::Penggalangan::PenggalanganDanaController < ApplicationController
  # before_action :
  #Untuk membuat penggalangan dana beasiswa
  def createPenggalanganDanaBeasiswa
    durasi_pengajuan, error_message, status_penggalangan_dana_beasiswa = V1::Pengajuan::PengajuanBantuanController.new.getDurasiPengajuanBeasiswa(return_json: false)
    date_now = DateTime.now
    first_day_of_month = Date.new(date_now.year, date_now.month, 1)
    if (7..14).include?(date_now.day.to_i)
      week_number = 2
    elsif (14..21).include?(date_now.day.to_i)
      week_number = 3
    elsif (21..28).include?(date_now.day.to_i)
      week_number = 4
    elsif (28..31).include?(date_now.day.to_i)
      week_number = 5
    end

    total_nominal_terkumpul = Constants::NOMINAL_PENGGALANGAN_DANA_BARU
    status = Enums::StatusPenggalanganDanaBeasiswa::ONGOING
    waktu_dimulai = DateTime.now
    next_month = first_day_of_month.next_month(12)
    waktu_berakhir = next_month - 1
    penanggung_jawab = PenanggungJawab.penanggung_jawab_jtk_berbagi
    if status_penggalangan_dana_beasiswa == Enums::StatusPenggalanganDanaBeasiswa::NULL
      if date_now.day.to_i > 7
        return render_error_response("Gagal membuat penggalangan dana Beasiswa karena sudah minggu ke #{week_number} di Bulan #{date_now.strftime("%B")}!")
      else
        penggalangan_dana_beasiswa_new = PenggalanganDanaBeasiswa.new(
          penggalangan_dana_beasiswa_id: randomize_penggalangan_dana_beasiswa_id(),
          waktu_dimulai: waktu_dimulai,
          waktu_berakhir: waktu_berakhir,
          judul: params[:judul],
          deskripsi: params[:deskripsi],
          target_dana: params[:target_dana],
          target_penerima: params[:target_penerima],
          total_nominal_terkumpul: total_nominal_terkumpul,
          status: status,
          penanggung_jawab_id: penanggung_jawab.first.role
        )
        
        if penggalangan_dana_beasiswa_new.save
          render_success_response(Constants::RESPONSE_CREATED, {penggalangan_dana_beasiswa: penggalangan_dana_beasiswa_new}, Constants::STATUS_CREATED)
        else
          render_error_response({ penggalangan_dana_beasiswa: penggalangan_dana_beasiswa_new.errors.full_messages})
        end
      end
    else
      penggalangan_dana_beasiswa_existing = PenggalanganDanaBeasiswa.on_going.first
      bantuan_dana_beasiswa_existing = BantuanDanaBeasiswa.pengajuan_approved.where(penggalangan_dana_beasiswa_id: penggalangan_dana_beasiswa_existing.penggalangan_dana_beasiswa_id).first
      if status_penggalangan_dana_beasiswa == Enums::StatusPenggalanganDanaBeasiswa::FUNDRAISING_PERIOD or status_penggalangan_dana_beasiswa == Enums::StatusPenggalanganDanaBeasiswa::SUBMITION_PERIOD
        return render_error_response("Periode Penggalangan Dana sebelumnya belum tahap penyaluran!")
      elsif !bantuan_dana_beasiswa_existing.present?
        return render_error_response("Penggalangan Dana Beasiswa sebelumnya belum terdapat penerima dana!")
      end

      if date_now.day.to_i > 7
        return render_error_response("Gagal membuat penggalangan dana Beasiswa karena sudah minggu ke #{week_number} di Bulan #{date_now.strftime("%B")}!")
      else
        penggalangan_dana_beasiswa_new = PenggalanganDanaBeasiswa.new(
          penggalangan_dana_beasiswa_id: randomize_penggalangan_dana_beasiswa_id(),
          waktu_dimulai: waktu_dimulai,
          waktu_berakhir: waktu_berakhir,
          judul: params[:judul],
          deskripsi: params[:deskripsi],
          target_dana: params[:target_dana],
          target_penerima: params[:target_penerima],
          total_nominal_terkumpul: total_nominal_terkumpul,
          status: status,
          penanggung_jawab_id: penanggung_jawab.first.role
        )

        if penggalangan_dana_beasiswa_new.save
          render_success_response(Constants::RESPONSE_CREATED, {penggalangan_dana_beasiswa: penggalangan_dana_beasiswa_new}, Constants::STATUS_CREATED)
        else
          render_error_response({ penggalangan_dana_beasiswa: penggalangan_dana_beasiswa_new.errors.full_messages})
        end
      end
    end
  end

  def createPenggalanganDanaNonBeasiswa
    is_civitas_pengaju = CivitasAkademika.where(nomor_induk: params[:nomor_induk_penanggung_jawab]).first
    is_civitas_penerima = CivitasAkademika.where(nomor_induk: params[:nomor_induk_penerima]).first

    penerima_non_beasiswa_on_going = PenerimaNonBeasiswa.where(nomor_induk: params[:nomor_induk_penerima]).first
    is_penerima_non_beasiswa_on_going = 0
    if penerima_non_beasiswa_on_going.present?
      penanggung_jawab_non_beasiswa_on_going = PenanggungJawabNonBeasiswaHasPenerimaNonBeasiswa.where(penerima_non_beasiswa_id: penerima_non_beasiswa_on_going.nomor_induk)
      penanggung_jawab_non_beasiswa_on_going.each do |data|
        bantuan_dana_non_beasiswa_on_going = BantuanDanaNonBeasiswa.pengajuan_approved.where(penanggung_jawab_non_beasiswa_id: data.penanggung_jawab_non_beasiswa_id).first
        if bantuan_dana_non_beasiswa_on_going.present?
          is_penerima_non_beasiswa_on_going = 1
        end
      end
    end

    puts "A"
    
    if is_penerima_non_beasiswa_on_going == 1
      puts "B"
      return render_error_response("Penggalangan Dana Sedang Berlangsung!")
    end
    if is_civitas_pengaju.present? && is_civitas_penerima.present?
      puts "BB"
      return render_error_response("NIM/NIP Penanggung Jawab dan Penerima Tidak terdaftar di dalam sistem!")
    elsif params[:nomor_induk_penanggung_jawab] == params[:nomor_induk_penerima]
      puts "BBB"
      return render_error_response("Penanggung Jawab harus berbeda!")
    end

    puts "AA"
    
    penerima_non_beasiswa_registered = PenerimaNonBeasiswa.where(nomor_induk: params[:nomor_induk_penerima]).first
    penanggung_jawab_non_beasiswa_registered = PenanggungJawabNonBeasiswa.where(nomor_induk: params[:nomor_induk_penanggung_jawab]).first
    
    if !penerima_non_beasiswa_registered.present?
      penerima_non_beasiswa = PenerimaNonBeasiswa.new(
        nama: is_civitas_penerima.present? ? is_civitas_penerima.nama : params[:nama_penerima],
        nomor_induk: params[:nomor_induk_penerima],
        nomor_telepon: params[:nomor_telepon_penerima]
        )
    else
      penerima_non_beasiswa = penerima_non_beasiswa_registered
    end
      
    if !penanggung_jawab_non_beasiswa_registered.present?
      penanggung_jawab_non_beasiswa = PenanggungJawabNonBeasiswa.new(
        nama: is_civitas_pengaju.present? ? is_civitas_pengaju.nama : params[:nama_penanggung_jawab],
        nomor_induk: params[:nomor_induk_penanggung_jawab],
        nomor_telepon: params[:nomor_induk_penanggung_jawab]
        )
    else
      penanggung_jawab_non_beasiswa = penanggung_jawab_non_beasiswa_registered
    end
    puts "AAAA"
    waktu_galang_dana = DateTime.parse(params[:waktu_galang_dana])
    if (waktu_galang_dana - DateTime.now).to_i + 1 < 1
      return render_error_response("Tanggal harus lebih dari hari sekarang!")
    end
    
    puts "AAAAA"
    penanggungjawabnonbeasiswa_has_penerimanonbeasiswa_registered = PenanggungJawabNonBeasiswaHasPenerimaNonBeasiswa.where(penanggung_jawab_non_beasiswa_id: params[:nomor_induk_penanggung_jawab]).first
    penerimanonbeasiswa_has_penanggungjawabnonbeasiswa_registered = PenanggungJawabNonBeasiswaHasPenerimaNonBeasiswa.where(penerima_non_beasiswa_id: params[:nomor_induk_penerima]).first
    if !penanggungjawabnonbeasiswa_has_penerimanonbeasiswa_registered.present? and penerimanonbeasiswa_has_penanggungjawabnonbeasiswa_registered.present?
      if penerimanonbeasiswa_has_penanggungjawabnonbeasiswa_registered.penanggung_jawab_non_beasiswa_id != params[:nomor_induk_penanggung_jawab]
        penerima_non_beasiswa.penanggung_jawab_non_beasiswa << penanggung_jawab_non_beasiswa
      end
      puts "AAAAAA"
    elsif !penerimanonbeasiswa_has_penanggungjawabnonbeasiswa_registered.present? and penanggungjawabnonbeasiswa_has_penerimanonbeasiswa_registered.present?
      if penanggungjawabnonbeasiswa_has_penerimanonbeasiswa_registered.penerima_non_beasiswa_id != params[:nomor_induk_penerima]
        penanggung_jawab_non_beasiswa.penerima_non_beasiswa << penerima_non_beasiswa
      end
    elsif !penerimanonbeasiswa_has_penanggungjawabnonbeasiswa_registered.present? and !penanggungjawabnonbeasiswa_has_penerimanonbeasiswa_registered.present?
      penanggung_jawab_non_beasiswa.penerima_non_beasiswa << penerima_non_beasiswa
    end
    
    puts "AAAAAAA"
    rekening_bank_owned = RekeningBank.where(nomor_rekening: params[:nomor_rekening]).first
    rekening_bank_registered = RekeningBank.where(penerima_non_beasiswa_id: params[:nomor_induk_penerima]).first
    if rekening_bank_registered.present?
      rekening_bank = rekening_bank_registered
    elsif rekening_bank_owned.present?
      return render_error_response("Nomor Rekening sudah terdaftar!")
    else
      rekening_bank = RekeningBank.new(rekening_bank_params)
      rekening_bank.assign_attributes({
        penerima_non_beasiswa: penerima_non_beasiswa
      })
    end
    puts "AAAAAAAA"
    
    bantuan_dana_non_beasiswa = BantuanDanaNonBeasiswa.new(bantuan_dana_non_beasiswa_params)
    
    bantuan_dana_non_beasiswa.assign_attributes({
      bantuan_dana_non_beasiswa_id: randomize_bantuan_dana_non_beasiswa_id(),
      waktu_galang_dana: waktu_galang_dana,
      bukti_butuh_bantuan: "-",
      total_nominal_terkumpul: Constants::NOMINAL_PENGGALANGAN_DANA_BARU,
      penanggung_jawab_non_beasiswa: penanggung_jawab_non_beasiswa,
      status_pengajuan: Enums::StatusPengajuan::APPROVED
    })
    puts "AAAAAAAA"
    
    if bantuan_dana_non_beasiswa.save && penerima_non_beasiswa.save && penanggung_jawab_non_beasiswa.save && rekening_bank.save
      render_success_response(Constants::RESPONSE_SUCCESS,{ penerima_non_beasiswa: penerima_non_beasiswa, penanggung_jawab_non_beasiswa: penanggung_jawab_non_beasiswa, rekening_bank: rekening_bank, bantuan_dana_non_beasiswa: bantuan_dana_non_beasiswa}, Constants::STATUS_CREATED)
    else
      render_error_response({ 
        penerima_non_beasiswa: penerima_non_beasiswa.errors.full_messages, 
        penanggung_jawab_non_beasiswa: penanggung_jawab_non_beasiswa.errors.full_messages, 
        rekening_bank: rekening_bank.errors.full_messages,
        bantuan_dana_non_beasiswa: bantuan_dana_non_beasiswa.errors.full_messages
      })
    end
    puts "AAAAAAAAA"
  end

  def getPenggalanganDanaBeasiswa
    penggalangan_dana_beasiswa = PenggalanganDanaBeasiswa.on_going
    data_penggalangan_dana_beasiswa = []
    if !penggalangan_dana_beasiswa.present?
      data_penggalangan_dana_beasiswa = []
    else
      penggalangan_dana_beasiswa.each do |data|
        new_data_penggalangan_dana_beasiswa = data.attributes.merge({
          durasi: getDurasiPenggalanganDana(data, "beasiswa"),
          dana_yang_dibutuhkan: data.target_dana * data.target_penerima,
          total_donatur: getTotalDonaturInPenggalanganDana(data, "beasiswa")
        })
        new_data_penggalangan_dana_beasiswa["penggalangan_dana_id"] = new_data_penggalangan_dana_beasiswa.delete("penggalangan_dana_beasiswa_id")        

        data_penggalangan_dana_beasiswa << new_data_penggalangan_dana_beasiswa
      end
    end
    
    return data_penggalangan_dana_beasiswa.first
  end

  def getPenggalanganDanaNonBeasiswa
    penggalangan_dana_non_beasiswa = BantuanDanaNonBeasiswa.pengajuan_approved

    if !penggalangan_dana_non_beasiswa.present?
      data_penggalangan_dana_non_beasiswa = []
    else
      data_penggalangan_dana_non_beasiswa = []
      if penggalangan_dana_non_beasiswa.length > 1
        penggalangan_dana_non_beasiswa.each do |data|
          new_data_penggalangan_dana_non_beasiswa = data.attributes.merge({
            durasi: getDurasiPenggalanganDana(data.bantuan_dana_non_beasiswa_id, "nonbeasiswa"),
            total_donatur: getTotalDonaturInPenggalanganDana(data.bantuan_dana_non_beasiswa_id, "nonbeasiswa")
          })
          new_data_penggalangan_dana_non_beasiswa["penggalangan_dana_id"] = new_data_penggalangan_dana_non_beasiswa.delete("bantuan_dana_non_beasiswa_id")
          new_data_penggalangan_dana_non_beasiswa["judul"] = new_data_penggalangan_dana_non_beasiswa.delete("judul_galang_dana")
          new_data_penggalangan_dana_non_beasiswa["deskripsi"] = new_data_penggalangan_dana_non_beasiswa.delete("deskripsi_galang_dana")
          data_penggalangan_dana_non_beasiswa << new_data_penggalangan_dana_non_beasiswa
        end
        data_penggalangan_dana_non_beasiswa = data_penggalangan_dana_non_beasiswa.reverse
      else
        new_data_penggalangan_dana_non_beasiswa = penggalangan_dana_non_beasiswa.first.attributes.merge({
          durasi: getDurasiPenggalanganDana(penggalangan_dana_non_beasiswa.first.bantuan_dana_non_beasiswa_id, "nonbeasiswa"),
          total_donatur: getTotalDonaturInPenggalanganDana(penggalangan_dana_non_beasiswa.first.bantuan_dana_non_beasiswa_id, "nonbeasiswa")
        })
        new_data_penggalangan_dana_non_beasiswa["penggalangan_dana_id"] = new_data_penggalangan_dana_non_beasiswa.delete("bantuan_dana_non_beasiswa_id")
        new_data_penggalangan_dana_non_beasiswa["judul"] = new_data_penggalangan_dana_non_beasiswa.delete("judul_galang_dana")
        new_data_penggalangan_dana_non_beasiswa["deskripsi"] = new_data_penggalangan_dana_non_beasiswa.delete("deskripsi_galang_dana")
        data_penggalangan_dana_non_beasiswa = new_data_penggalangan_dana_non_beasiswa
      end
    end
    return data_penggalangan_dana_non_beasiswa
  end

  def getAllPenggalanganDana
    penggalangan_dana_beasiswa = getPenggalanganDanaBeasiswa()
    penggalangan_dana_non_beasiswa = getPenggalanganDanaNonBeasiswa()
  
    if !penggalangan_dana_beasiswa.present? and !penggalangan_dana_non_beasiswa.present?
      return render_error_response("Tidak ada Penggalangan Dana yang berlangsung")
    end
  
    list_data_penggalangan_dana = []
    list_penggalangan_dana_non_beasiswa = []
  
    list_data_penggalangan_dana << penggalangan_dana_beasiswa
    list_data_penggalangan_dana << penggalangan_dana_non_beasiswa
  
    new_data_pengajuan = list_data_penggalangan_dana.flatten
    
    render_success_response(Constants::RESPONSE_SUCCESS, new_data_pengajuan, Constants::STATUS_OK)
  end

  def getNominalPenyaluran(data_penggalangan_dana)
    nominal_penyaluran = []
    data_penggalangan_dana.pengajuan_bantuan_id.each_with_index do |data,index|
      if index > 0
        penerima_beasiswa = Pengajuan::PengajuanBantuan.penggalangan_dana.where(:id => data).first
        beasiswa = Pengajuan::Beasiswa.where(id: penerima_beasiswa.beasiswa_id).first
        nominal_penyaluran << beasiswa.nominal_penyaluran
      end
    end
    @total_penyaluran = nominal_penyaluran.inject(0, :+)
    return @total_penyaluran
  end

  def getDurasiPenggalanganDana(penggalangan_dana_id, jenis)
    if jenis == "beasiswa"
      penggalangan_dana_beasiswa = penggalangan_dana_id
      end_date = penggalangan_dana_id.waktu_berakhir
    else
      penggalangan_dana_non_beasiswa = BantuanDanaNonBeasiswa.where(bantuan_dana_non_beasiswa_id: penggalangan_dana_id).first
      end_date = penggalangan_dana_non_beasiswa.waktu_galang_dana
    end
    durasi = (end_date - DateTime.now).to_i + 1
    if durasi < 1
      if jenis == "beasiswa"
        penggalangan_dana_beasiswa.update(status: Enums::StatusPenggalanganDanaBeasiswa::DONE)
        bantuan_dana_beasiswa = BantuanDanaBeasiswa.approved.where(penggalangan_dana_beasiswa_id: penggalangan_dana_beasiswa.penggalangan_dana_beasiswa_id)
        if bantuan_dana_beasiswa.present?
          bantuan_dana_beasiswa.each do |data_bantuan_dana|
            data_bantuan_dana.update(status_pengajuan: Enums::StatusPengajuan::DONE)
          end
        end
        
      else
        penggalangan_dana_non_beasiswa.update({
          status_pengajuan: Enums::StatusPengajuan::DONE,
          status_penyaluran: Enums::StatusPenyaluran::PENDING
        })
      end
    end
  
    return durasi
  end

  def getPenggalanganDanaNonBeasiswaByKategori
    valid_categories = ["Medis", "Bencana", "Duka"]
    unless valid_categories.include?(params[:kategori])
      return render_error_response("Kategori #{params[:kategori]} tidak ada!, Kategori hanya Medis/Bencana/Duka")
    end
  
    penggalangan_dana_non_beasiswa = getPenggalanganDanaNonBeasiswa()
  
    if !penggalangan_dana_non_beasiswa.present?
      return render_error_response("Penggalangan Dana Non Beasiswa tidak ada!")
    end

    filter_by_kategori = penggalangan_dana_non_beasiswa.select { |item| item['kategori'] == params[:kategori] }
    if !filter_by_kategori.present?
      return render_error_response("Penggalangan Dana Non Beasiswa berdasarkan Kategori #{params[:kategori]} tidak ada!")
    end
    render_success_response(Constants::RESPONSE_SUCCESS, filter_by_kategori, Constants::STATUS_OK)
  end

  #Memilih Kasus Penggalangan Dana
  def selectPenggalanganDana
    penggalangan_dana_beasiswa = PenggalanganDanaBeasiswa.on_going.where(penggalangan_dana_beasiswa_id: params[:id]).first
    penggalangan_dana_non_beasiswa = BantuanDanaNonBeasiswa.pengajuan_approved.where(bantuan_dana_non_beasiswa_id: params[:id]).first

    if !penggalangan_dana_beasiswa.present? and !penggalangan_dana_non_beasiswa.present?
      return render_error_response("id penggalangan dana tidak dapat ditemukan!")
    end

    if penggalangan_dana_beasiswa.present?
      bantuan_dana_beasiswa = BantuanDanaBeasiswa.pengajuan_approved.where(penggalangan_dana_beasiswa_id: penggalangan_dana_beasiswa.penggalangan_dana_beasiswa_id)
      array_of_penerima_beasiswa = []
      bantuan_dana_beasiswa.each do |data|
        array_of_penerima_beasiswa << data.attributes.merge({
          mahasiswa_id: Mahasiswa.where(nim: data.mahasiswa_id).first
        })
      end
      selected_penggalangan_dana = penggalangan_dana_beasiswa.attributes.merge({
        penanggung_jawab: PenanggungJawab.penanggung_jawab_jtk_berbagi.first.nama,
        penerima_dana: array_of_penerima_beasiswa,
        jenis: "Beasiswa",
        data_donatur: getDataDonaturInPenggalanganDana(penggalangan_dana_beasiswa.penggalangan_dana_beasiswa_id, "Beasiswa"),
        durasi: getDurasiPenggalanganDana(penggalangan_dana_beasiswa, "beasiswa"),
      })
      selected_penggalangan_dana["penggalangan_dana_id"] = selected_penggalangan_dana.delete("penggalangan_dana_beasiswa_id")
    else
      penanggung_jawab_non_beasiswa = PenanggungJawabNonBeasiswa.where(nomor_induk: penggalangan_dana_non_beasiswa.penanggung_jawab_non_beasiswa_id).first
      penanggung_jawab_penerima_non_beasiswa = PenanggungJawabNonBeasiswaHasPenerimaNonBeasiswa.where(penanggung_jawab_non_beasiswa_id: penanggung_jawab_non_beasiswa.nomor_induk).first
      penerima_non_beasiswa = PenerimaNonBeasiswa.where(nomor_induk: penanggung_jawab_penerima_non_beasiswa.penerima_non_beasiswa_id).first
      selected_penggalangan_dana = penggalangan_dana_non_beasiswa.attributes.merge({
        penanggung_jawab: penanggung_jawab_non_beasiswa,
        penerima_dana: penerima_non_beasiswa,
        jenis: "NonBeasiswa",
        data_donatur: getDataDonaturInPenggalanganDana(penggalangan_dana_non_beasiswa.bantuan_dana_non_beasiswa_id, "NonBeasiswa"),
        durasi: getDurasiPenggalanganDana(penggalangan_dana_non_beasiswa, "non_beasiswa"),
      })
      selected_penggalangan_dana["penggalangan_dana_id"] = selected_penggalangan_dana.delete("bantuan_dana_non_beasiswa_id")
      selected_penggalangan_dana["judul"] = selected_penggalangan_dana.delete("judul_galang_dana")
      selected_penggalangan_dana["deskripsi"] = selected_penggalangan_dana.delete("deskripsi_galang_dana")
    end
    render_success_response(Constants::RESPONSE_SUCCESS, selected_penggalangan_dana, Constants::STATUS_OK)
  end

  def getTotalDonaturInPenggalanganDana(penggalangan_dana_id, jenis)
    if jenis == "beasiswa"
      donasi = Donasi.approved.where(penggalangan_dana_beasiswa_id: penggalangan_dana_id.penggalangan_dana_beasiswa_id)
      if !donasi.present?
        total_donatur = 0
      else
        total_donatur = donasi.pluck(:donatur_id).length
      end
    else
      donasi = Donasi.approved.where(bantuan_dana_non_beasiswa_id: penggalangan_dana_id)
      if !donasi.present?
        total_donatur = 0
      else
        total_donatur = donasi.pluck(:donatur_id).length
      end
    end
    return total_donatur
  end

  def getTotalPenggalanganDana
    penggalangan_dana_beasiswa_count = PenggalanganDanaBeasiswa.all.length
    penggalangan_dana_non_beasiswa_count = BantuanDanaNonBeasiswa.where.not(status_pengajuan: Enums::StatusPengajuan::NEW).all.length
    total_penggalangan_dana = penggalangan_dana_beasiswa_count + penggalangan_dana_non_beasiswa_count
    render json: {
      response_code: Constants::RESPONSE_SUCCESS, 
      response_message: "Success", 
      data: total_penggalangan_dana
    }, status: :ok
  end

  def getDataDonaturInPenggalanganDana(penggalangan_dana_id = 0, jenis)
    data_donatur_donasi = []    
    if jenis == "Beasiswa"
      donasi = Donasi.approved.where(penggalangan_dana_beasiswa_id: penggalangan_dana_id)
      if !donasi.present?
        sorted_data_donatur = []
      else
        donasi.each do |data|
          donatur = Donatur.donatur_registered.where(nomor_telepon: data.donatur_id).first
          data_donatur_donasi << {nama: donatur.nama, nominal_donasi: data.nominal_donasi}
        end
        sorted_data_donatur = data_donatur_donasi.sort_by { |item| -item[:nominal_donasi] }
      end

    else
      donasi = Donasi.approved.where(bantuan_dana_non_beasiswa_id: penggalangan_dana_id)
      
      if !donasi.present?
        sorted_data_donatur = []
      else
        donasi.each do |data|
          donatur = Donatur.donatur_registered.where(nomor_telepon: data.donatur_id).first
          data_donatur_donasi << {nama: donatur.nama, nominal_donasi: data.nominal_donasi}
        end
        sorted_data_donatur = data_donatur_donasi.sort_by { |item| -item[:nominal_donasi] }
      end

    end
    return sorted_data_donatur
  end

  private
  def rekening_bank_params
    params.permit(:nama_bank, :nomor_rekening, :nama_pemilik_rekening)
  end

  #form non_beasiswa
  def bantuan_dana_non_beasiswa_params
    params.permit(
      :judul_galang_dana, 
      :waktu_galang_dana, 
      :deskripsi_galang_dana, 
      :dana_yang_dibutuhkan,
      :kategori,
    )
  end

  def find_pengajuan_bantuan_by_penggalangan_dana(penggalangan_dana)
    pengajuan_bantuan_id = Array(penggalangan_dana.pengajuan_bantuan_id).first
    Pengajuan::PengajuanBantuan.penggalangan_dana.where(id: pengajuan_bantuan_id).first
  end

  def randomize_penggalangan_dana_beasiswa_id
    begin
      return penggalangan_dana_beasiswa_id = SecureRandom.random_number(1_000_000)
    end while PenggalanganDanaBeasiswa.where(penggalangan_dana_beasiswa_id: penggalangan_dana_beasiswa_id).exists?
  end

  def randomize_bantuan_dana_non_beasiswa_id
    begin
      return bantuan_dana_beasiswa_id = SecureRandom.random_number(1_000_000)
    end while BantuanDanaNonBeasiswa.where(bantuan_dana_non_beasiswa_id: bantuan_dana_non_beasiswa_id).exists?
  end
end
