class V1::CivitasAkademikaController < ApplicationController
def importExcelCivitasAkademika
  unless params[:file].present?
    return render json: {
      response_code: Constants::ERROR_CODE_VALIDATION,
      response_message: "No file uploaded!"
    }, status: :unprocessable_entity
  end

  unless File.extname(params[:file].original_filename) == '.xlsx'
    return render json: {
      response_code: Constants::ERROR_CODE_VALIDATION,
      response_message: "File must be an Excel file (.xlsx)!"
    }, status: :unprocessable_entity
  end

  begin
    errors = import_data(params[:file].tempfile)

    if errors.empty?
      render json: {
        response_code: Constants::RESPONSE_CREATED,
        response_message: "Data imported successfully!"
      }, status: :created
    else
      limited_errors = errors.first(1)
      extra_count = errors.size - limited_errors.size

      formatted_errors = limited_errors.map { |err| "- #{err}" }.join("\n")
      summary = extra_count.positive? ? "\n...and #{extra_count} more row(s) with similar errors." : ""

      render json: {
        response_code: Constants::ERROR_CODE_VALIDATION,
        response_message: "Import failed with errors:\n#{formatted_errors}#{summary}"
      }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: {
      response_code: Constants::ERROR_CODE_SERVER,
      response_message: "Server error: #{e.message}"
    }, status: :internal_server_error
  end
end

  private

  def getAllCivitasAkademika
    civitas_akademika = CivitasAkademika.all.to_a
    if civitas_akademika.empty?
      render json: {
        response_code: Constants::ERROR_CODE_VALIDATION,
        response_message: "No Civitas Akademika data found!"
      }, status: :unprocessable_entity
    else
      render json: {
        response_code: Constants::RESPONSE_SUCCESS,
        response_message: "Success",
        data: civitas_akademika
      }, status: :ok
    end
  end

  def search
    civitas_akademika = CivitasAkademika.all
    if civitas_akademika.empty?
      render json: {
        response_code: Constants::ERROR_CODE_VALIDATION,
        response_message: "No Civitas Akademika data found!"
      }, status: :unprocessable_entity
    else
      searched_civitas_akademika = civitas_akademika.select do |data|
        data.attributes.values.grep(/^#{Regexp.escape(params[:keyword] || '')}/i).any?
      end
      if searched_civitas_akademika.empty?
        render json: {
          response_code: Constants::ERROR_CODE_VALIDATION,
          response_message: "No Civitas Akademika found for keyword: #{params[:keyword]}!"
        }, status: :unprocessable_entity
      else
        render json: {
          response_code: Constants::RESPONSE_SUCCESS,
          response_message: "Success",
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
        errors << "Database table 'civitasakademika' does not exist"
        return errors
      end

      xls = Roo::Excelx.new(file.path)
      Rails.logger.info "Excel file loaded: #{xls.sheets}"
      xls.each_row_streaming(offset: 1).with_index(2) do |row, row_index|
        nomor_induk = row[0]&.value&.to_s
        nama = row[1]&.value&.to_s
        Rails.logger.info "Processing row #{row_index}: nomor_induk=#{nomor_induk}, nama=#{nama}"

        if nomor_induk.blank?
          errors << "Row #{row_index}: nomor_induk is missing"
          next
        end
        unless nomor_induk.match?(/\A\d+\z/)
          errors << "Row #{row_index}: nomor_induk must be a number"
          next
        end
        if nama.blank?
          errors << "Row #{row_index}: nama is missing"
          next
        end

        begin
          civitas = CivitasAkademika.find_or_initialize_by(nomor_induk: nomor_induk)
          civitas.nama = nama
          civitas.save!
        rescue ActiveRecord::RecordInvalid => e
          errors << "Row #{row_index}: #{e.message}"
        end
      end
    rescue StandardError => e
      errors << "Failed to process Excel file: #{e.message}"
    end
    errors
  end
end
