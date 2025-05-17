require 'swagger_helper'

describe 'Rekapitulasi API' do
    path '/v1/rekapitulasi/getAllBatchRekapitulasiBeasiswa' do
        get 'Get All Batch Beasiswa' do
          tags 'Rekapitulasi'
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
    
    path '/v1/rekapitulasi/getRekapitulasiBeasiswa' do
        post 'Get Rekapitulasi Beasiswa' do
            tags 'Rekapitulasi'
            consumes 'application/json'
            produces 'application/json'
            parameter name: :body, in: :body, schema: {
                type: :object,
                properties: {
                    id: {type: :integer, example: 607068},
                    month: {type: :string, example: "September"},
                },
                required: []
            }
            response '200', 'Successfull' do
                schema type: :object
                run_test!
            end
            response '422', 'Unprocessable Entity' do
                schema type: :object,
                        properties: {
                        response_message: {type: :string, example: "Pengajuan Non Beasiswa tidak dapat ditemukan!"},
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

    path '/v1/rekapitulasi/getBulanRekapitulasiBeasiswa' do
        post 'Get Bulan Rekapitulasi Beasiswa' do
            tags 'Rekapitulasi'
            consumes 'application/json'
            produces 'application/json'
            parameter name: :body, in: :body, schema: {
                type: :object,
                properties: {
                    id: {type: :integer, example: 607068}
                },
                required: []
            }
            response '200', 'Successfull' do
                schema type: :object
                run_test!
            end
            response '422', 'Unprocessable Entity' do
                schema type: :object,
                        properties: {
                        response_message: {type: :string, example: "Pengajuan Non Beasiswa tidak dapat ditemukan!"},
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
    
    path '/v1/rekapitulasi/getRekapitulasiNonBeasiswa' do
        get 'Get Rekapitulasi Dana Non Beasiswa' do
            tags 'Rekapitulasi'
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
    
    path '/v1/rekapitulasi/selectPenyaluranBeasiswa' do
        post 'Select Penyaluran Beasiswa' do
            tags 'Rekapitulasi'
            consumes 'application/json'
            produces 'application/json'
            parameter name: :body, in: :body, schema: {
                type: :object,
                properties: {
                    id: {type: :integer, example: 607068},
                    nominal_penyaluran: {type: :integer, example: 10000},
                    is_penyaluran: {type: :string, example: "true"},
                    bulan_penyaluran: {type: :integer, example: 1},
                },
                required: []
            }
            response '200', 'Successfull' do
                schema type: :object
                run_test!
            end
            response '422', 'Unprocessable Entity' do
                schema type: :object,
                        properties: {
                        response_message: {type: :string, example: "Pengajuan Non Beasiswa tidak dapat ditemukan!"},
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
    
    path '/v1/rekapitulasi/selectPenyaluranNonBeasiswa' do
        post 'Select Penyaluran Non Beasiswa' do
            tags 'Rekapitulasi'
            consumes 'application/json'
            produces 'application/json'
            parameter name: :body, in: :body, schema: {
            type: :object,
            properties: {
                id: {type: :integer, example: 448725},
                is_penyaluran: {type: :string, example: "true"},
            },
            required: []
            }
            response '200', 'Successfull' do
                schema type: :object
                run_test!
            end
            response '422', 'Unprocessable Entity' do
                schema type: :object,
                        properties: {
                        response_message: {type: :string, example: "Pengajuan Non Beasiswa tidak dapat ditemukan!"},
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

    path '/v1/rekapitulasi/getApprovedDonasiByPenggalanganDana' do
        post 'Get All Approved Donasi by Penggalangan Dana' do
            tags 'Rekapitulasi'
            consumes 'application/json'
            produces 'application/json'
            parameter name: :body, in: :body, schema: {
                type: :object,
                properties: {
                    id: {type: :integer, example: 752325},
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
