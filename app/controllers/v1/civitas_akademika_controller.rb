class V1::CivitasAkademikaController < ApplicationController
def importExcelCivitasAkademika
  unless params[:file].present?
    return render json: {
      response_code: Constants::ERROR_CODE_VALIDATION,
      response_message: "Tidak ada file yang diunggah!"
    }, status: :unprocessable_entity
  end

  unless File.extname(params[:file].original_filename) == '.xlsx'
    return render json: {
      response_code: Constants::ERROR_CODE_VALIDATION,
      response_message: "File harus berupa file Excel (.xlsx)!"
    }, status: :unprocessable_entity
  end

  begin
    errors = import_data(params[:file].tempfile)

    if errors.empty?
      render json: {
        response_code: Constants::RESPONSE_CREATED,
        response_message: "Data berhasil diimpor!"
      }, status: :created
    else
      limited_errors = errors.first(1)
      extra_count = errors.size - limited_errors.size

      formatted_errors = limited_errors.map { |err| "- #{err}" }.join("\n")
      summary = extra_count.positive? ? "\n...dan #{extra_count} baris lain dengan kesalahan serupa." : ""

      render json: {
        response_code: Constants::ERROR_CODE_VALIDATION,
        response_message: "Impor gagal dengan kesalahan\n#{formatted_errors}#{summary}"
      }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: {
      response_code: Constants::ERROR_CODE_SERVER,
      response_message: "Kesalahan server: #{e.message}"
    }, status: :internal_server_error
  end
end

  private

  def getAllCivitasAkademika
    civitas_akademika = CivitasAkademika.all.to_a
    if civitas_akademika.empty?
      render json: {
        response_code: Constants::ERROR_CODE_VALIDATION,
        response_message: "Data Civitas Akademika tidak ditemukan!"
      }, status: :unprocessable_entity
    else
      render json: {
        response_code: Constants::RESPONSE_SUCCESS,
        response_message: "Berhasil",
        data: civitas_akademika
      }, status: :ok
    end
  end

  def search
    civitas_akademika = CivitasAkademika.all
    if civitas_akademika.empty?
      render json: {
        response_code: Constants::ERROR_CODE_VALIDATION,
        response_message: "Data Civitas Akademika tidak ditemukan!"
      }, status: :unprocessable_entity
    else
      searched_civitas_akademika = civitas_akademika.select do |data|
        data.attributes.values.grep(/^#{Regexp.escape(params[:keyword] || '')}/i).any?
      end
      if searched_civitas_akademika.empty?
        render json: {
          response_code: Constants::ERROR_CODE_VALIDATION,
          response_message: "Tidak ada Civitas Akademika yang ditemukan untuk kata kunci: #{params[:keyword]}!"
        }, status: :unprocessable_entity
      else
        render json: {
          response_code: Constants::RESPONSE_SUCCESS,
          response_message: "Berhasil",
          data: searched_civitas_akademika
        }, status: :ok
      end
    end
  end

  private

  def import_data(file)
    errors = []
    begin
      unless ActiveRecord::Base.connection.table_exists?('civitasakademika')
        errors << "Tabel database 'civitasakademika' tidak ada"
        return errors
      end

      xls = Roo::Excelx.new(file.path)
      Rails.logger.info "File Excel dimuat: #{xls.sheets}"
      xls.each_row_streaming(offset: 1).with_index(2) do |row, row_index|
        nomor_induk = row[0]&.value&.to_s
        nama = row[1]&.value&.to_s
        Rails.logger.info "Memproses baris #{row_index}: nomor_induk=#{nomor_induk}, nama=#{nama}"

        if nomor_induk.blank?
          errors << "Baris #{row_index}: nnomor_induk kosong"
          next
        end
        unless nomor_induk.match?(/\A\d+\z/)
          errors << "Baris #{row_index}: nomor_induk harus berupa angka"
          next
        end
        if nama.blank?
          errors << "Baris #{row_index}: nama kosong"
          next
        end

        begin
          civitas = CivitasAkademika.find_or_initialize_by(nomor_induk: nomor_induk)
          civitas.nama = nama
          civitas.save!
        rescue ActiveRecord::RecordInvalid => e
          errors << "Baris #{row_index}: #{e.message}"
        end
      end
    rescue StandardError => e
      errors << "Gagal memproses file Excel: #{e.message}"
    end
    errors
  end
end
