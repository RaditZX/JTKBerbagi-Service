require 'rails_helper'

RSpec.describe V1::CivitasAkademikaController, type: :request do
  let(:valid_headers) { { 'ACCEPT' => 'application/json' } }
  let(:valid_excel_path) { Rails.root.join('spec/fixtures/files/valid_civitas.xlsx') }
  let(:invalid_excel_path) { Rails.root.join('spec/fixtures/files/invalid_civitas.xlsx') }
  let(:invalid_format_path) { Rails.root.join('spec/fixtures/files/sampletext.txt') }
  let(:controller_instance) { described_class.new }

  describe "POST /v1/civitas_akademika/import_excel_civitas_akademika" do
    context "when file is not provided" do
      it "returns error for missing file" do
        post "/v1/civitas_akademika/importExcelCivitasAkademika", headers: valid_headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['response_code']).to eq(422)
        expect(json['response_message']).to eq('Tidak ada file yang diunggah!')
      end
    end

    context 'when file is not .xlsx' do
      let(:invalid_file) { fixture_file_upload(invalid_format_path, 'text/plain') }

      it "returns error for wrong file type" do
        post "/v1/civitas_akademika/importExcelCivitasAkademika",
             params: { file: invalid_file },
             headers: valid_headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['response_code']).to eq(422)
        expect(json['response_message']).to eq('File harus berupa file Excel (.xlsx)!')
      end
    end

    context 'when valid Excel file is uploaded' do
      let(:valid_file) { fixture_file_upload(valid_excel_path, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') }

      it "returns success message" do
        post "/v1/civitas_akademika/importExcelCivitasAkademika",
             params: { file: valid_file },
             headers: valid_headers

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['response_code']).to eq(201)
        expect(json['response_message']).to eq('Data berhasil diimpor!')
      end
    end

    context 'when Excel file has invalid data' do
      let(:invalid_file) { fixture_file_upload(invalid_excel_path, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') }

      it "returns validation errors" do
        post "/v1/civitas_akademika/importExcelCivitasAkademika",
             params: { file: invalid_file },
             headers: valid_headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['response_code']).to eq(422)
        expect(json['response_message']).to include("Impor gagal dengan kesalahan")
        expect(json['response_message']).to include("nomor_induk harus berupa angka")
      end
    end

    context "when internal server error occurs" do
      before do
        allow_any_instance_of(V1::CivitasAkademikaController)
          .to receive(:import_data).and_raise(StandardError.new("Terjadi kesalahan"))
      end

      let(:excel_file) do
        fixture_file_upload(Rails.root.join("spec/fixtures/files/valid_civitas.xlsx"), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
      end

      it "returns server error" do
        post "/v1/civitas_akademika/importExcelCivitasAkademika",
             params: { file: excel_file },
             headers: valid_headers

        expect(response).to have_http_status(:internal_server_error)
        json = JSON.parse(response.body)
        expect(json['response_code']).to eq(500)
        expect(json['response_message']).to include('Kesalahan server: Terjadi kesalahan')
      end
    end
  end

  describe '#get_all_civitas_akademika (private method)' do
    let(:render_args) { [] }

    before do
      allow(controller_instance).to receive(:render) { |args| render_args << args }
    end

    context 'when no data exists' do
      before { CivitasAkademika.delete_all }
      it 'renders no data found message' do
        controller_instance.send(:get_all_civitas_akademika)
        expect(render_args).to include(
          hash_including(
            json: {
              response_code: 422,
              response_message: 'Data Civitas Akademika tidak ditemukan!'
            },
            status: :unprocessable_entity
          )
        )
      end
    end

    context 'when data exists' do
      before do
        CivitasAkademika.delete_all
        CivitasAkademika.create!(nomor_induk: '231511038', nama: 'Daffa Al Ghifari')
        CivitasAkademika.create!(nomor_induk: '231511039', nama: 'Daiva Raditya Pradipa')
      end
      it 'renders success with data' do
        controller_instance.send(:get_all_civitas_akademika)
        expect(render_args).to include(
          hash_including(
            json: {
              response_code: 200,
              response_message: 'Berhasil',
              data: an_instance_of(Array)
            },
            status: :ok
          )
        )
        json = render_args.find { |args| args[:json][:response_message] == 'Berhasil' }[:json]
        expect(json[:data].size).to eq(2)
        expect(json[:data].map { |d| d['nomor_induk'] }).to include('231511038', '231511039')
      end
    end
  end
end

RSpec.describe "V1::CivitasAkademikaController", type: :request do
  describe "POST /v1/civitas_akademika/updateRekeningMahasiswa" do
    RSpec.configure do |config|
      config.before(:suite) do
        Rails.application.load_seed
      end
    end
    let!(:mahasiswa) { Mahasiswa.find_by(nim: "231511038") }
    
    let(:valid_params) do
      {
        nim: "231511038",
        nama_bank: "Bank Baru",
        nomor_rekening: "999888777",
        nama_pemilik_rekening: "Pemilik Baru"
      }
    end

    let(:missing_params_rekening_mahasiswa) do
      {
        nim: "231511039",
        nama_bank: "Bank Baru",
        nomor_rekening: "999888777",
        nama_pemilik_rekening: "Pemilik Baru"
      }
    end

    let(:missing_params) do
      {
        nim: "231511038",
        nama_bank: "",
        nomor_rekening: "999888777",
        nama_pemilik_rekening: ""
      }
    end

    context "when mahasiswa does not exist" do
      it "returns 404 not found" do
        post "/v1/civitas_akademika/updateRekeningMahasiswa", params: { nim: "000000000" }
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)["error"]).to include("tidak ditemukan")
      end
    end

    context "when rekening bank does not exist" do
      it "returns 404 not found" do
        post "/v1/civitas_akademika/updateRekeningMahasiswa", params: missing_params_rekening_mahasiswa

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)["error"]).to include("belum terdaftar")
      end
    end

    context "when required parameters are missing" do
      it "returns 422 unprocessable entity" do
       post "/v1/civitas_akademika/updateRekeningMahasiswa", params: missing_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to include("Parameter tidak lengkap")
      end
    end

    context "when all parameters are valid" do
      it "updates the rekening bank and returns success" do
        post "/v1/civitas_akademika/updateRekeningMahasiswa", params: valid_params

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Rekening bank berhasil diperbarui")
        expect(json["rekening"]["nama_bank"]).to eq("Bank Baru")
        expect(json["rekening"]["nomor_rekening"]).to eq("999888777")
        expect(json["rekening"]["nama_pemilik_rekening"]).to eq("Pemilik Baru")
      end
    end
  end
end