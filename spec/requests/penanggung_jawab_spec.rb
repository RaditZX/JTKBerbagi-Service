require 'swagger_helper'

describe 'Penanggung Jawab API' do
  path '/v1/user/penanggung_jawab/createPenanggungJawab' do
    post 'Create User' do
      tags 'PenanggungJawab'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
            nama: {type: :string, example: "Admin JTK Berbagi"},
            role: {type: :integer, example: 0},
            username: {type: :string, example: "AdminJTKBerbagi"},
            nama_bank: {type: :string, example: "BSI"},
            nomor_rekening: {type: :string, example: "219382932"},
            nama_pemilik_rekening: {type: :string, example: "Gemintang Sangkaji Furqon"},
            password: {type: :string, example: "12345678"},
            password_confirmation: {type: :string, example: "12345678"},
            nomor_telepon: {type: :string, example: "081232132318"},
        },
        required: []
      }
      response '201', 'Created' do
        schema type: :object
        run_test!
      end
      response '422', 'Unprocessable Entity' do
        schema type: :object,
              properties: {
                response_message: {type: :string, example: "Data tidak boleh kosong!"},
                response_code: {type: :integer, example: 422}
              }
        run_test!
      end
      response '401', 'Unauthorized' do
        schema type: :object,
              properties: {
                response_message: {type: :string, example: "Tidak memiliki akses!"},
                response_code: {type: :integer, example: 401}
              }
        run_test!
      end
    end
  end

  path '/v1/user/penanggung_jawab/getBankByPenanggungJawab' do
    get 'Get Bank By Admin' do
      tags 'PenanggungJawab'
      consumes 'application/json'
      produces 'application/json'
      response '200', 'Success' do
        schema type: :object
        run_test!
      end
      response '422', 'Unprocessable Entity' do
        schema type: :object,
              properties: {
                response_message: {type: :string, example: "Data tidak Ditemukan"},
                response_code: {type: :integer, example: 422}
              }
        run_test!
      end
      response '401', 'Unauthorized' do
        schema type: :object,
              properties: {
                response_message: {type: :string, example: "Tidak memiliki akses!"},
                response_code: {type: :integer, example: 401}
              }
        run_test!
      end
    end
  end
end
