require 'swagger_helper'

describe 'Penggalangan Dana API' do
  path '/v1/penggalangan/penggalangan_dana/createPenggalanganDanaBeasiswa' do
    post 'Create Penggalangan Dana Beasiswa' do
      tags 'Penggalangan Dana'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
            judul: {type: :string, example: "Penggalangan Dana untuk Beasiswa"},
            deskripsi: {type: :string, example: "Penggalangan Dana untuk Beasiswa Mahasiswa JTK"},
            target_dana: {type: :integer, example: 600000},
            target_penerima: {type: :integer, example: 6},
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
                response_message: {type: :string, example: "Data yang dimasukan salah!"},
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

  path '/v1/penggalangan/penggalangan_dana/createPenggalanganDanaNonBeasiswa' do
    post 'Create Penggalangan Dana Non Beasiswa' do
      tags 'Penggalangan Dana'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          nama_penanggung_jawab: {type: :string, example: "Gemintang"},
          nomor_induk_penanggung_jawab: {type: :string, example: "191524009"},
          nomor_telepon_penanggung_jawab: {type: :string, example: "082118397901"},
          nomor_rekening: {type: :string, example: "21312214"},
          nama_pemilik_rekening: {type: :string, example: "Gemintang"},
          nama_bank: {type: :string, example: "BSI"},
          judul_galang_dana: {type: :string, example: "Galang Dana untuk Pengobatan"},
          waktu_galang_dana: {type: :string, example: "02-10-2023"},
          deskripsi_galang_dana: {type: :string, example: "Membutuhkan biaya untuk pengobatan"},
          dana_yang_dibutuhkan: {type: :integer, example: 1000000},
          nama_penerima: {type: :string, example: "Tatang"},
          nomor_induk_penerima: {type: :string, example: "191524024"},
          nomor_telepon_penerima: {type: :string, example: "082118397901"},
          kategori: {type: :string, example: "Medis"},
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
                response_message: {type: :string, example: "Data yang dimasukan salah!"},
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

  path '/v1/penggalangan/penggalangan_dana/getPenggalanganDanaNonBeasiswaByKategori' do
    post 'Get Penggalangan Dana Non Beasiswa By Kategori' do
      tags 'Penggalangan Dana'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
            kategori: {type: :string, example: "Medis"},
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
                response_message: {type: :string, example: "Data yang dimasukan salah!"},
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
  path '/v1/penggalangan/penggalangan_dana/selectPenggalanganDana' do
    post 'Select Penggalangan Dana' do
      tags 'Penggalangan Dana'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
            id: {type: :integer, example: 729245},
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
                response_message: {type: :string, example: "Penggalangan dana tidak dapat ditemukan!"},
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

  path '/v1/penggalangan/penggalangan_dana/getAllPenggalanganDana' do
    get 'Get All Penggalangan Dana' do
      tags 'Penggalangan Dana'
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

  path '/v1/penggalangan/penggalangan_dana/getTotalPenggalanganDana' do
    get 'Get Total All Penggalangan Dana' do
      tags 'Penggalangan Dana'
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
