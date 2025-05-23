require 'rails_helper'

RSpec.describe V1::CivitasAkademikaController, type: :request do
  let(:valid_headers) { { "ACCEPT" => "application/json" } }

  describe "POST /v1/civitas_akademika/importExcelCivitasAkademika" do
    context "when file is not provided" do
      it "returns error for missing file" do
        post "/v1/civitas_akademika/importExcelCivitasAkademika", headers: valid_headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["response_code"]).to eq("ERROR_CODE_VALIDATION")
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
        expect(json["response_code"]).to eq("ERROR_CODE_VALIDATION")
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
        expect(json["response_code"]).to eq("RESPONSE_CREATED")
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
        expect(json["response_code"]).to eq("ERROR_CODE_VALIDATION")
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
        expect(json["response_code"]).to eq("ERROR_CODE_SERVER")
        expect(json["response_message"]).to include("Server error: Something went wrong")
      end
    end
  end

  describe "GET /v1/civitas_akademika/getAllCivitasAkademika" do
    context "when no civitas akademika data exists" do
      it "returns error for no data found" do
        get "/v1/civitas_akademika/getAllCivitasAkademika", headers: valid_headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["response_code"]).to eq("ERROR_CODE_VALIDATION")
        expect(json["response_message"]).to eq("No Civitas Akademika data found!")
      end
    end

    context "when civitas akademika data exists" do
      before do
        CivitasAkademika.create!(nomor_induk: "12345678", nama: "Daffa Al Ghifari")
        CivitasAkademika.create!(nomor_induk: "87654321", nama: "Budi Santoso")
      end

      it "returns all civitas akademika data" do
        get "/v1/civitas_akademika/getAllCivitasAkademika", headers: valid_headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["response_code"]).to eq("RESPONSE_SUCCESS")
        expect(json["response_message"]).to eq("Success")
        expect(json["data"]).to be_an(Array)
        expect(json["data"].size).to eq(2)
        expect(json["data"].map { |d| d["nomor_induk"] }).to contain_exactly("12345678", "87654321")
        expect(json["data"].map { |d| d["nama"] }).to contain_exactly("Daffa Al Ghifari", "Budi Santoso")
      end
    end
  end

  describe "GET /v1/civitas_akademika/search" do
    context "when no civitas akademika data exists" do
      it "returns error for no data found" do
        get "/v1/civitas_akademika/search", params: { keyword: "Daffa" }, headers: valid_headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["response_code"]).to eq("ERROR_CODE_VALIDATION")
        expect(json["response_message"]).to eq("No Civitas Akademika data found!")
      end
    end

    context "when civitas akademika data exists" do
      before do
        CivitasAkademika.create!(nomor_induk: "12345678", nama: "Daffa Al Ghifari")
        CivitasAkademika.create!(nomor_induk: "87654321", nama: "Budi Santoso")
      end

      context "when keyword matches data" do
        it "returns matching civitas akademika data" do
          get "/v1/civitas_akademika/search", params: { keyword: "Daffa" }, headers: valid_headers

          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json["response_code"]).to eq("RESPONSE_SUCCESS")
          expect(json["response_message"]).to eq("Success")
          expect(json["data"]).to be_an(Array)
          expect(json["data"].size).to eq(1)
          expect(json["data"].first["nama"]).to eq("Daffa Al Ghifari")
        end
      end

      context "when keyword does not match any data" do
        it "returns error for no matching data" do
          get "/v1/civitas_akademika/search", params: { keyword: "Zulkarnain" }, headers: valid_headers

          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)
          expect(json["response_code"]).to eq("ERROR_CODE_VALIDATION")
          expect(json["response_message"]).to eq("No Civitas Akademika found for keyword: Zulkarnain!")
        end
      end

      context "when keyword param is missing" do
        it "returns all civitas akademika data" do
          get "/v1/civitas_akademika/search", headers: valid_headers

          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json["response_code"]).to eq("RESPONSE_SUCCESS")
          expect(json["response_message"]).to eq("Success")
          expect(json["data"]).to be_an(Array)
          expect(json["data"].size).to eq(2)
          expect(json["data"].map { |d| d["nomor_induk"] }).to contain_exactly("12345678", "87654321")
        end
      end
    end
  end
end