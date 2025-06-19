require 'rails_helper'

RSpec.describe V1::CivitasAkademikaController, type: :request do
  let(:valid_headers) { { 'ACCEPT' => 'application/json' } }
  let(:valid_excel_path) { Rails.root.join('spec/fixtures/files/valid_civitas.xlsx') }
  let(:invalid_excel_path) { Rails.root.join('spec/fixtures/files/invalid_civitas.xlsx') }
  let(:invalid_format_path) { Rails.root.join('spec/fixtures/files/sampletext.txt') }
  let(:controller_instance) { described_class.new }

  describe 'POST /v1/civitas_akademika/importExcelCivitasAkademika' do
    context 'when no file is uploaded' do
      it 'returns a validation error' do
        post '/v1/civitas_akademika/importExcelCivitasAkademika', headers: valid_headers
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['response_code']).to eq(422)
        expect(json['response_message']).to eq('Tidak ada file yang diunggah!')
      end
    end

    context 'when file is not .xlsx' do
      let(:invalid_file) { fixture_file_upload(invalid_format_path, 'text/plain') }

      it 'returns a validation error' do
        post '/v1/civitas_akademika/importExcelCivitasAkademika', params: { file: invalid_file }, headers: valid_headers
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['response_code']).to eq(422)
        expect(json['response_message']).to eq('File harus berupa file Excel (.xlsx)!')
      end
    end

    context 'when valid Excel file is uploaded' do
      let(:valid_file) { fixture_file_upload(valid_excel_path, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') }

      it 'imports successfully' do
        post '/v1/civitas_akademika/importExcelCivitasAkademika', params: { file: valid_file }, headers: valid_headers
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['response_code']).to eq(201)
        expect(json['response_message']).to eq('Data berhasil diimpor!')
      end
    end

    context 'when Excel file has invalid data' do
      let(:invalid_file) { fixture_file_upload(invalid_excel_path, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') }

      it 'returns formatted errors' do
        post '/v1/civitas_akademika/importExcelCivitasAkademika', params: { file: invalid_file }, headers: valid_headers
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['response_code']).to eq(422)
        expect(json['response_message']).to include('Impor gagal dengan kesalahan')
        expect(json['response_message']).to include('nomor_induk harus berupa angka')
      end
    end

    context 'when table does not exist' do
      let(:valid_file) { fixture_file_upload(valid_excel_path, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') }

      before do
        allow(ActiveRecord::Base.connection).to receive(:table_exists?).with('civitasakademika').and_return(false)
      end

      it 'returns table not found error' do
        post '/v1/civitas_akademika/importExcelCivitasAkademika', params: { file: valid_file }, headers: valid_headers
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['response_code']).to eq(422)
        expect(json['response_message']).to include("Tabel database 'civitasakademika' tidak ada")
      end
    end

    context 'when internal server error occurs' do
      let(:valid_file) { fixture_file_upload(valid_excel_path, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') }

      before do
        allow_any_instance_of(V1::CivitasAkademikaController)
          .to receive(:import_data).and_raise(StandardError.new('Terjadi kesalahan'))
      end

      it 'returns server error' do
        post '/v1/civitas_akademika/importExcelCivitasAkademika', params: { file: valid_file }, headers: valid_headers
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

  describe '#search (private method)' do
    let(:render_args) { [] }

    before do
      allow(controller_instance).to receive(:render) { |args| render_args << args }
    end

    context 'when no data exists' do
      it 'renders no data found message' do
        controller_instance.params = { keyword: 'Daffa' }
        controller_instance.send(:search)
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
        CivitasAkademika.create!(nomor_induk: '231511038', nama: 'Daffa Al Ghifari')
        CivitasAkademika.create!(nomor_induk: '231511039', nama: 'Daiva Raditya Pradipa')
      end

      context 'when keyword matches data' do
        it 'renders matching records' do
          controller_instance.params = { keyword: 'Daffa' }
          controller_instance.send(:search)
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
          expect(json[:data].size).to eq(1)
          expect(json[:data].first['nama']).to eq('Daffa Al Ghifari')
        end
      end

      context 'when keyword does not match any record' do
        it 'renders not found message' do
          controller_instance.params = { keyword: 'Zzz' }
          controller_instance.send(:search)
          expect(render_args).to include(
            hash_including(
              json: {
                response_code: 422,
                response_message: 'Tidak ada Civitas Akademika yang ditemukan untuk kata kunci: Zzz!'
              },
              status: :unprocessable_entity
            )
          )
        end
      end

      context 'when keyword is missing' do
        it 'renders all records' do
          controller_instance.params = {}
          controller_instance.send(:search)
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
end