
class V1::CivitasAkademikaController < ApplicationController
  def importExcelCivitasAkademika
    if params[:file].present? && File.extname(params[:file].original_filename) == '.xlsx'
      import_data(params[:file].tempfile)
      render json: {
        response_code: Constants::RESPONSE_CREATED, 
        response_message: "Success",
        }, status: :created
    else
      render json: {
        response_code: Constants::ERROR_CODE_VALIDATION,
        response_message: "Import Excel Gagal!"
        }, status: :unprocessable_entity
    end
  end

  def getAllCivitasAkademika
    civitas_akademika = CivitasAkademika.all
    if not civitas_akademika.present?
      render json: {
        response_code: Constants::ERROR_CODE_VALIDATION,
        response_message: "Data Civitas Akademika tidak ada!"
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
    if not civitas_akademika.present?
      render json: {
        response_code: Constants::ERROR_CODE_VALIDATION,
        response_message: "Data Civitas Akademika tidak ada!"
        }, status: :unprocessable_entity
    else
      searched_civitas_akademika = civitas_akademika.select do | data | data.attributes.values.grep(/^#{params[:keyword]}/i).any? end
      if not searched_civitas_akademika.present?
        render json: {
          response_code: Constants::ERROR_CODE_VALIDATION,
          response_message: "Tidak ada data Civitas Akademika berdasarkan #{params[:keyword]}!"
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

  def universal_autocomplete
    keyword = params[:term]
    table = params[:table]&.downcase
    search_column = params[:column]

    if keyword.blank? || keyword.length < 2 || table.blank? || search_column.blank?
      render json: [], status: :ok
      return
    end

    # Whitelist lengkap: nama tabel => { model: ModelClass, id_column: "nama_kolom_id", allowed_columns: ["nama", "telepon", ...] }
    allowed_tables = {
      "mahasiswa" => {
        model: Mahasiswa,
        id_column: "nim",
        allowed_columns: ["nim", "nama", "nomor_telepon"]
      },
      "civitas_akademika" => {
        model: CivitasAkademika,
        id_column: "nomor_induk",
        allowed_columns: ["nomor_induk", "nama"]
      },
      # Tambahkan tabel lain di sini
    }

    config = allowed_tables[table]
    unless config
      render json: { error: "Tabel tidak dikenali" }, status: :unprocessable_entity
      return
    end

    model = config[:model]
    id_column = config[:id_column]
    allowed_columns = config[:allowed_columns]

    unless allowed_columns.include?(search_column)
      render json: { error: "Kolom tidak diizinkan" }, status: :unprocessable_entity
      return
    end

    # valid_extra_columns = extra_columns.select { |col| allowed_columns.include?(col) }

    suggestions = model
                .where("#{search_column} LIKE ?", "%#{keyword}%")
                .limit(10)

    results = suggestions.map(&:attributes)

    render json: results, status: :ok
  rescue => e
    Rails.logger.error "Universal Autocomplete error: #{e.message}"
    render json: { error: "Terjadi kesalahan saat memproses permintaan autocomplete" }, status: :internal_server_error
  end

  def get_civitas
    keyword = params[:keyword].to_s.strip
    type = params[:type].to_s.strip

    # 1. Validasi Input yang Lebih Baik
    unless ['nomor_induk', 'nama'].include?(type)
      render json: { error: "Tipe pencarian tidak valid. Gunakan 'nomor_induk' atau 'nama'." }, status: :bad_request
      return
    end

    if keyword.length < 2
      render json: { error: "Keyword pencarian harus memiliki minimal 2 karakter." }, status: :bad_request
      return
    end

    # 2. Query yang Aman dan Fleksibel
    #    Menggunakan array untuk keamanan dari SQL Injection
    if type == 'nomor_induk'
      # Untuk nomor_induk, cari kecocokan persis
      results = CivitasAkademika.where(nomor_induk: keyword)
    else # type == 'nama'
      # Untuk nama, cari kecocokan sebagian (case-insensitive)
      # Ini akan menemukan keyword di mana saja dalam nama
      sanitized_keyword = ActiveRecord::Base.sanitize_sql_like(keyword)
      results = CivitasAkademika.where("nama ILIKE ?", "%#{sanitized_keyword}%")
    end

    # 3. Pilih kolom yang diinginkan dan render semua hasil (bukan hanya .first)
    render json: results.select(:nomor_induk, :nama), status: :ok
  
  rescue StandardError => e
    render json: { error: "Terjadi kesalahan internal: #{e.message}" }, status: :internal_server_error
  end

  private

  def import_data(file)
    xls = Roo::Excelx.new(file.path)
    xls.each_row_streaming(offset: 1) do |row|
      nama = row[1]&.value
      nomor_induk = row[0]&.value
      CivitasAkademika.create!(nama: nama, nomor_induk: nomor_induk)
    end
  end
end