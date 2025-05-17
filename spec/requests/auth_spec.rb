require 'swagger_helper'

describe 'Authentication API' do
  path '/v1/authentication/loginPenanggungJawab' do
    post 'Login Penanggung Jawab' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
            username: {type: :string, example: "AdminJTKBerbagi"},
            password: {type: :string, example: "12345678"},
        },
        required: []
      }
      response '200', 'Successfull' do
        schema type: :object
        run_test!
      end
      response '401', 'Error' do
        schema type: :object,
              properties: {
                response_message: {type: :string, example: "Username salah"},
                response_code: {type: :integer, example: 401}
              }
        run_test!
      end
    end
  end

  path '/v1/authentication/loginDonatur' do
    post 'Login Donatur' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
            nomor_telepon: {type: :string, example: "082118397901"},
            password: {type: :string, example: "12345678"},
        },
        required: []
      }
      response '200', 'Successfull' do
        schema type: :object
        run_test!
      end
      response '401', 'Error' do
        schema type: :object,
              properties: {
                response_message: {type: :string, example: "Username salah"},
                response_code: {type: :integer, example: 401}
              }
        run_test!
      end
    end
  end
end