require 'swagger_helper'

describe 'Civitas Akademika API' do
  path '/v1/civitas_akademika/importExcelCivitasAkademika' do
    post 'Import Excel Civitas Akademika' do
      tags 'Civitas Akademika'
      consumes 'multipart/form-data'
      produces 'application/json'
      parameter in: :formData, name: :file, type: :file
      response '200', 'Successfull' do
        schema type: :object
        run_test!
      end
      response '422', 'Error' do
        schema type: :object,
              properties: {
                response_message: {type: :string, example: "Import Excel gagal!"},
                response_code: {type: :integer, example: 401}
              }
        run_test!
      end
      response '401', 'Error' do
        schema type: :object,
              properties: {
                response_message: {type: :string, example: "Tidak ada akses!"},
                response_code: {type: :integer, example: 401}
              }
        run_test!
      end
    end
  end

  path '/v1/civitas_akademika/getAllCivitasAkademika' do
    get 'Get All Data Civitas Akademika' do
      tags 'Civitas Akademika'
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
  
  path '/v1/civitas_akademika/search' do
    post 'Search Attributes in Civitas Akademika' do
      tags 'Civitas Akademika'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
            keyword: {type: :string, example: "191524009"},
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
                response_message: {type: :string, example: "Data tidak dapat ditemukan!"},
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