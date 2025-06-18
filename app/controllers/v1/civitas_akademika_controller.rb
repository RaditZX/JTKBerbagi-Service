
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

def updateRekeningMahasiswa
    mahasiswa = Mahasiswa.find_by(nim: params[:nim])

    unless mahasiswa
      render json: { error: "Mahasiswa dengan NIM #{params[:nim]} tidak ditemukan" }, status: :not_found
      return
    end

    rekening_bank = RekeningBank.find_by(mahasiswa_id: mahasiswa.id)

    unless rekening_bank
      render json: { error: "Rekening bank mahasiswa belum terdaftar" }, status: :not_found
      return
    end

    # ✅ Tambahkan pengecekan parameter
    required_params = %i[nama_bank nomor_rekening nama_pemilik_rekening]
    missing_params = required_params.select { |key| params[key].blank? }

    unless missing_params.empty?
      render json: { error: "Parameter tidak lengkap: #{missing_params.join(', ')}" }, status: :unprocessable_entity
      return
    end

    if rekening_bank.update(
      nama_bank: params[:nama_bank],
      nomor_rekening: params[:nomor_rekening],
      nama_pemilik_rekening: params[:nama_pemilik_rekening]
    )
      render json: { message: "Rekening bank berhasil diperbarui", rekening: rekening_bank }, status: :ok
    else
      render json: { error: rekening_bank.errors.full_messages }, status: :unprocessable_entity
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
    errors = []
    records = []

    begin
      unless ActiveRecord::Base.connection.table_exists?('civitasakademika')
        errors << "Tabel database 'civitasakademika' tidak ada"
        return errors
      end

      xls = Roo::Excelx.new(file.path)
      Rails.logger.info "File Excel dimuat: #{xls.sheets}"

      nomor_induk_dari_excel = []
      row_data = []
      xls.each_row_streaming(offset: 1).with_index(2) do |row, row_index|
        nomor_induk = row[0]&.value&.to_s
        nama = row[1]&.value&.to_s

        if nomor_induk.blank?
          errors << "Baris #{row_index}: nomor_induk kosong"
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

        nomor_induk_dari_excel << nomor_induk
        row_data << { nomor_induk: nomor_induk, nama: nama, row_index: row_index }
      end

      existing = CivitasAkademika.where(nomor_induk: nomor_induk_dari_excel).index_by(&:nomor_induk)

      row_data.each do |data|
        record = existing[data[:nomor_induk]] || CivitasAkademika.new(nomor_induk: data[:nomor_induk])
        record.nama = data[:nama]

        if record.valid?
          records << record
        else
          errors << "Baris #{data[:row_index]}: #{record.errors.full_messages.join(', ')}"
        end
      end

      CivitasAkademika.import records, on_duplicate_key_update: [:nama], validate: false if records.any?

    rescue => e
      errors << "Gagal memproses file Excel: #{e.message}"
    end
    errors
  end

  


end
