class V1::RekapitulasiController < ApplicationController
    # before_action :
  def getRekapitulasiBeasiswa
    if params[:id].blank?
      return render_error_response("Id tidak boleh kosong!")
    end
    if params[:month].blank?
      return render_error_response("Month tidak boleh kosong!")
    end
    penggalangan_dana_beasiswa = PenggalanganDanaBeasiswa.where(penggalangan_dana_beasiswa_id: params[:id]).first
    if !penggalangan_dana_beasiswa.present?
      return render_error_response("Batch Rekapitulasi Beasiswa tidak dapat ditemukan!")
    end
    bantuan_dana_beasiswa = BantuanDanaBeasiswa.rekapitulasi.where(penggalangan_dana_beasiswa_id: params[:id])
    array_of_penerima_beasiswa = []
    bantuan_dana_beasiswa.each do |data|
      array_of_penerima_beasiswa << data.attributes.merge({
        mahasiswa: data.mahasiswa,
        rekening_bank: data.mahasiswa.rekening_bank.first,
      })
    end

    list_month = getBulanRekapitulasiBeasiswa(penggalangan_dana_beasiswa.penggalangan_dana_beasiswa_id, return_json: false)
    
    if penggalangan_dana_beasiswa.status == Enums::StatusPenggalanganDanaBeasiswa::ONGOING && list_month.index(DateTime.now.strftime('%B')) < list_month.index(params[:month])
      rekapitulasi_dana = [
        saldo_awal: 0,
        total_pemasukan: 0,
        total_pengeluaran: 0,
        saldo_akhir: 0
      ]
      new_rekapitulasi_dana = rekapitulasi_dana.first
    else
      rekapitulasi_dana = calculate_rekapitulasi(penggalangan_dana_beasiswa.penggalangan_dana_beasiswa_id, params[:month])
      rekapitulasi_dana_by_month = rekapitulasi_dana.find { |entry| entry[:month] == params[:month] }
      new_rekapitulasi_dana = rekapitulasi_dana_by_month.except!(:month)   
    end

    filtered_penerima_beasiswa = array_of_penerima_beasiswa.select do |item|
      list_month.index(params[:month]) > 5  &&
      item["status_penyaluran"][list_month.index(params[:month]) - 6].present?
    end

    rekapitulasi_donasi = getApprovedDonasiByPenggalanganDana(penggalangan_dana_beasiswa.penggalangan_dana_beasiswa_id, return_json:false)
    selected_rekapitulasi_donasi = rekapitulasi_donasi.select do |item|
      item["tanggal_approve"].strftime("%B") == params[:month]
    end

    rekapitulasi_beasiswa = [
      batch: penggalangan_dana_beasiswa.penggalangan_dana_beasiswa_id, 
      penerima_beasiswa: filtered_penerima_beasiswa, 
      rekapitulasi_dana: new_rekapitulasi_dana,
      rekapitulasi_donasi: selected_rekapitulasi_donasi
    ]
    render_success_response(Constants::RESPONSE_SUCCESS, rekapitulasi_beasiswa.first, Constants::STATUS_OK)
  end

  def calculate_rekapitulasi(penggalangan_dana_beasiswa, params_month)
    months = getBulanRekapitulasiBeasiswa(penggalangan_dana_beasiswa, return_json: false)
    saldo_awal = 0
    result = []
  
    months.each_with_index do |month, index|
      total_pemasukan = getTotalPemasukan(penggalangan_dana_beasiswa, month)
      total_pengeluaran = index > 5 ? getTotalPengeluaran(penggalangan_dana_beasiswa, index) : 0
      saldo_akhir = saldo_awal + total_pemasukan - total_pengeluaran
  
      month_result = {
        month: month,
        saldo_awal: saldo_awal,
        total_pemasukan: total_pemasukan,
        total_pengeluaran: total_pengeluaran,
        saldo_akhir: saldo_akhir
      }
  
      result << month_result
      saldo_awal = saldo_akhir
  
      break if month == params_month
    end
  
    return result
  end

  def getAllBatchRekapitulasiBeasiswa
    batch_beasiswa = PenggalanganDanaBeasiswa.all
    if !batch_beasiswa.present?
      return render_error_response("Data Batch Beasiswa tidak ada!")
    end
    render_success_response(Constants::RESPONSE_SUCCESS, batch_beasiswa.pluck(:penggalangan_dana_beasiswa_id), Constants::STATUS_OK)
  end

  def getRekapitulasiNonBeasiswa
    bantuan_dana_non_beasiswa = BantuanDanaNonBeasiswa.rekapitulasi
    if !bantuan_dana_non_beasiswa.present?
      return render_error_response("Tidak ada data Rekapitulasi Dana Non Beasiswa!")      
    end
    array_rekapitulasi_non_beasiswa = []
    bantuan_dana_non_beasiswa.each do |data|
      penanggung_jawab_non_beasiswa = PenanggungJawabNonBeasiswa.where(nomor_induk: data.penanggung_jawab_non_beasiswa_id).first
      penanggung_jawab_penerima = PenanggungJawabNonBeasiswaHasPenerimaNonBeasiswa.where(penanggung_jawab_non_beasiswa_id: penanggung_jawab_non_beasiswa.nomor_induk).first
      penerima_non_beasiswa = PenerimaNonBeasiswa.where(nomor_induk: penanggung_jawab_penerima.penerima_non_beasiswa_id).first
      rekening_bank = RekeningBank.where(penerima_non_beasiswa_id: penerima_non_beasiswa.nomor_induk).first
      array_rekapitulasi_non_beasiswa << data.attributes.merge({
        penanggung_jawab_non_beasiswa_id: penanggung_jawab_non_beasiswa,
        penerima_non_beasiswa: penerima_non_beasiswa,
        rekening_bank: rekening_bank
      })
    end
    render_success_response(Constants::RESPONSE_SUCCESS, array_rekapitulasi_non_beasiswa.reverse, Constants::STATUS_OK)
  end

  def selectPenyaluranBeasiswa
    if params[:id].blank?
      return render_error_response("Id tidak boleh kosong!")
    end
    bantuan_dana_beasiswa = BantuanDanaBeasiswa.rekapitulasi.where(bantuan_dana_beasiswa_id: params[:id]).first
    if !bantuan_dana_beasiswa.present?
      return render_error_response("Penerima Beasiswa tidak dapat ditemukan!")
    end

    if params[:bulan_penyaluran].blank?
      return render_error_response("Bulan Penyaluran tidak boleh kosong!")
    end

    unless [1, 2, 3, 4, 5, 6].include?(params[:bulan_penyaluran])
      return render_error_response("Bulan Penyaluran hanya dapat 1, 2, 3, 4, 5, 6")
    end

    if bantuan_dana_beasiswa.status_penyaluran[params[:bulan_penyaluran] - 1] == 1
      return render_error_response("Bantuan Dana Beasiswa telah disalurkan pada bulan ke#{params[:bulan_penyaluran]}")
    end

    list_bulan_rekap = getBulanRekapitulasiBeasiswa(bantuan_dana_beasiswa.penggalangan_dana_beasiswa_id, return_json:false)
    index_bulan = list_bulan_rekap.index(DateTime.now.strftime('%B'))
    puts params[:bulan_penyaluran] 
    puts"khhjk" 
    puts index_bulan
    if params[:bulan_penyaluran] != index_bulan - 5
      return render_error_response("Bulan Penyaluran yang diinputkan berbeda dengan bulan sekarang!")
    end
    
    if params[:is_penyaluran].blank?
      return render_error_response("is_penyaluran tidak boleh kosong!")
    end

    unless %w[true false].include?(params[:is_penyaluran])
      return render_error_response("is_penyaluran hanya dapat true atau false!")
    end
    
    if params[:nominal_penyaluran].blank?
      return render_error_response("Nominal Penyaluran tidak boleh kosong!")
    end

    if params[:is_penyaluran] == "true"
      bantuan_dana_beasiswa.nominal_penyaluran[params[:bulan_penyaluran] - 1] = params[:nominal_penyaluran]
      bantuan_dana_beasiswa.status_penyaluran[params[:bulan_penyaluran] - 1] = Enums::StatusPenyaluran::DELIVERED
      bantuan_dana_beasiswa.nominal_penyaluran << Constants::NOMINAL_PENYALURAN
      bantuan_dana_beasiswa.status_penyaluran << Enums::StatusPenyaluran::PENDING
    else
      bantuan_dana_beasiswa.nominal_penyaluran[params[:bulan_penyaluran] - 1] = params[:nominal_penyaluran]
      bantuan_dana_beasiswa.status_penyaluran[params[:bulan_penyaluran] - 1] = Enums::StatusPenyaluran::DELIVERED
    end
    bantuan_dana_beasiswa.save
    render_success_response(Constants::RESPONSE_SUCCESS, bantuan_dana_beasiswa, Constants::STATUS_OK)
  end

  def selectPenyaluranNonBeasiswa
    if params[:id].blank?
      return render_error_response("Id tidak boleh kosong!")
    end

    bantuan_dana_non_beasiswa = BantuanDanaNonBeasiswa.penyaluran.where(bantuan_dana_non_beasiswa_id: params[:id]).first
    if !bantuan_dana_non_beasiswa.present?
      return render_error_response("Id Bantuan Dana Non Beasiswa tidak ditemukan!")
    end

    if params[:is_penyaluran].blank?
      return render_error_response("is_penyaluran tidak boleh kosong!")
    end

    unless %w[true false].include?(params[:is_penyaluran])
      return render_error_response("is_penyaluran hanya dapat true atau false!")
    end
    if params[:is_penyaluran] == "true"
      status_penyaluran = Enums::StatusPenyaluran::DELIVERED
    else
      status_penyaluran = Enums::StatusPenyaluran::PENDING
    end
    bantuan_dana_non_beasiswa.assign_attributes(status_penyaluran: status_penyaluran)
    if bantuan_dana_non_beasiswa.save
      render_success_response(Constants::RESPONSE_SUCCESS, bantuan_dana_non_beasiswa, Constants::STATUS_OK)
    else
      render_error_response(bantuan_dana_non_beasiswa: bantuan_dana_non_beasiswa.errors.full_messages)
    end
  end

  def getTotalPengeluaran(penggalangan_dana_id, month)
    bantuan_dana_beasiswa = BantuanDanaBeasiswa.rekapitulasi.where(penggalangan_dana_beasiswa_id: penggalangan_dana_id)
    array_of_nominal_penyaluran = []
    bantuan_dana_beasiswa.each do |data|
      array_of_nominal_penyaluran << data.nominal_penyaluran[month - 6]
    end
    if contains_empty_arrays = array_of_nominal_penyaluran.any? { |element| element == [] or element == nil }
      array_of_nominal_penyaluran.reject! { |element| element == [] or element == nil}
    end
    total_pengeluaran = array_of_nominal_penyaluran.sum
    return total_pengeluaran
  end

  def getSaldoAwal(penggalangan_dana_beasiswa_id)
    penggalangan_dana_beasiswa = PenggalanganDanaBeasiswa.where(penggalangan_dana_beasiswa_id: penggalangan_dana_beasiswa_id).first
    penggalangan_dana_beasiswa_existing = PenggalanganDanaBeasiswa.done.where("penggalangan_dana_beasiswa_id > ?", penggalangan_dana_beasiswa.penggalangan_dana_beasiswa_id).order("penggalangan_dana_beasiswa_id DESC").first
    if !penggalangan_dana_beasiswa_existing.present?
      saldo_awal = 0
    else
      donasi = Donasi.approved.where(penggalangan_dana_beasiswa_id: penggalangan_dana_beasiswa_existing)
      total_donasi = donasi.pluck(:nominal_donasi).inject(0, :+)
      array_of_nominal_penyaluran = []
      penggalangan_dana_beasiswa.bantuan_dana_beasiswa.each do |data|
        array_of_nominal_penyaluran << data.nominal_penyaluran
      end
      total_penyaluran = array_of_nominal_penyaluran.sum.sum
      saldo_awal = total_donasi - total_penyaluran
    end
    return saldo_awal
  end

  def getTotalPemasukan(penggalangan_dana_id, month)
    donasi = Donasi.approved.where(penggalangan_dana_beasiswa_id: penggalangan_dana_id)
    if !donasi.present?
      total_donasi = 0
    else
      donasi_filter = donasi.select { |data| data["tanggal_approve"].strftime('%B') == month }
      total_donasi = donasi_filter.pluck(:nominal_donasi).inject(0, :+)
    end
    return total_donasi
  end

  def getBulanRekapitulasiBeasiswa(penggalangan_dana_id = nil, return_json: true)
    if penggalangan_dana_id == nil
      penggalangan_dana_id = params[:id]
    end
    penggalangan_dana_beasiswa = PenggalanganDanaBeasiswa.where(penggalangan_dana_beasiswa_id: penggalangan_dana_id).first
    if !penggalangan_dana_beasiswa.present?
      error_message = "Penggalangan Dana Beasiswa tidak dapat ditemukan!"
    end
    start_date = penggalangan_dana_beasiswa.waktu_dimulai
    end_date = penggalangan_dana_beasiswa.waktu_berakhir
    array_of_month = []
    while start_date <= end_date
      array_of_month << start_date.strftime('%B')
      start_date = start_date.next_month
    end
    
    if return_json
      if error_message.present?
        render_error_response(error_message)
      else
        render_success_response(Constants::RESPONSE_SUCCESS, array_of_month, Constants::STATUS_OK)
      end
    else
      return array_of_month
    end
    
  end

  def getApprovedDonasiByPenggalanganDana(penggalangan_dana_id = nil, return_json: true)
    if penggalangan_dana_id == nil
      if params[:id].blank?
        return render_error_response("Id tidak boleh kosong!")
      end
    end
    
  
    bantuan_dana_non_beasiswa = BantuanDanaNonBeasiswa.where(bantuan_dana_non_beasiswa_id: params[:id]).first
    penggalangan_dana_beasiswa = PenggalanganDanaBeasiswa.where(penggalangan_dana_beasiswa_id: penggalangan_dana_id).first
  
    array_of_donasi_approved = []
  
    if bantuan_dana_non_beasiswa.present?
      donasi_approved = Donasi.approved.where(bantuan_dana_non_beasiswa_id: params[:id])
    else
      donasi_approved = Donasi.approved.where(penggalangan_dana_beasiswa_id: penggalangan_dana_id)
    end
  
    donasi_approved.each do |data|
      donatur = Donatur.donatur_registered.where(nomor_telepon: data.donatur_id).first
      if bantuan_dana_non_beasiswa.present?
        array_of_donasi_approved << data.attributes.merge(
          bantuan_dana_non_beasiswa_id: bantuan_dana_non_beasiswa,
          donatur_id: donatur
        )
      else
        array_of_donasi_approved << data.attributes.merge(
          penggalangan_dana_beasiswa_id: penggalangan_dana_beasiswa,
          donatur_id: donatur
        )
      end
    end
  
    if return_json
      render_success_response(Constants::RESPONSE_SUCCESS, array_of_donasi_approved, Constants::STATUS_OK)
    else
      return array_of_donasi_approved
    end
  end
end
