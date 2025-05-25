require 'rails_helper'

RSpec.describe "V1::CivitasAkademikaController", type: :request do
  let(:valid_headers) { { "ACCEPT" => "application/json" } }

  describe "POST /v1/civitas_akademika/import_excel_civitas_akademika" do
    context "when file is not provided" do
      it "returns error for missing file" do
        post "/v1/civitas_akademika/importExcelCivitasAkademika", headers: valid_headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["response_message"]).to eq("No file uploaded!")
      end
    end

    context "when uploaded file is not .xlsx" do
      let(:non_excel_file) do
        fixture_file_upload(Rails.root.join("spec/fixtures/files/sampletext.txt"), "text/plain")
      end

      it "returns error for wrong file type" do
        post "/v1/civitas_akademika/importExcelCivitasAkademika",
             params: { file: non_excel_file },
             headers: valid_headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["response_message"]).to eq("File must be an Excel file (.xlsx)!")
      end
    end

    context "when valid Excel file is uploaded with correct format" do
      let(:excel_file) do
        fixture_file_upload(Rails.root.join("spec/fixtures/files/valid_civitas.xlsx"), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
      end

      it "returns success message" do
        post "/v1/civitas_akademika/importExcelCivitasAkademika",
             params: { file: excel_file },
             headers: valid_headers

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["response_message"]).to eq("Data imported successfully!")
      end
    end

    context "when Excel contains invalid data" do
      let(:invalid_excel_file) do
        fixture_file_upload(Rails.root.join("spec/fixtures/files/invalid_civitas.xlsx"), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
      end

      it "returns validation errors" do
        post "/v1/civitas_akademika/importExcelCivitasAkademika",
             params: { file: invalid_excel_file },
             headers: valid_headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["response_message"]).to include("Import failed with errors")
      end
    end

    context "when internal server error occurs" do
      before do
        allow_any_instance_of(V1::CivitasAkademikaController)
          .to receive(:import_data).and_raise(StandardError.new("Something went wrong"))
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
        expect(json["response_message"]).to include("Server error: Something went wrong")
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
