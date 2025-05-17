require 'swagger_helper'

describe 'Pengajuan Bantuan API' do
  path '/v1/pengajuan/pengajuan_bantuan/createPengajuanBeasiswa' do
    post 'Create Pengajuan Beasiswa' do
      tags 'Pengajuan Bantuan'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
            nama: {type: :string, example: "Gemintang"},
            nim: {type: :string, example: "191524009"},
            nomor_telepon: {type: :string, example: "082118397901"},
            nomor_rekening: {type: :string, example: "21312214"},
            nama_pemilik_rekening: {type: :string, example: "Gemintang"},
            nama_bank: {type: :string, example: "BSI"},
            alasan_butuh_bantuan: {type: :string, example: "membutuhkan bantuan dana untuk kuliah"},
            golongan_ukt: {type: :integer, example: 1},
            kuitansi_pembayaran_ukt: {type: :string, example: "path"},
            gaji_orang_tua: {type: :integer, example: 4000000},
            bukti_slip_gaji_orang_tua: {type: :string, example: "path"},
            esai: {type: :string, example: "path"},
            jumlah_tanggungan_keluarga: {type: :integer, example: 2},
            biaya_transportasi: {type: :string, example: "100000"},
            biaya_konsumsi: {type: :string, example: "1000000"},
            biaya_internet: {type: :string, example: "1000000"},
            biaya_kos: {type: :string, example: "1000000"},
            total_pengeluaran_keluarga: {type: :integer, example: 5000000},
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
  path '/v1/pengajuan/pengajuan_bantuan/createPengajuanNonBeasiswa' do
    post 'Create Pengajuan Non Beasiswa' do
      tags 'Pengajuan Bantuan'
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
            bukti_butuh_bantuan: {type: :string, example: "path"},
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

  path '/v1/pengajuan/pengajuan_bantuan/createPenilaianEsai' do
    post 'Create Penilaian Esai Pengajuan Beasiswa' do
      tags 'Pengajuan Bantuan'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          id: {type: :integer, example: 763850},
          penilaian_esai: {type: :string, example: "Baik"},
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
                response_message: {type: :string, example: "Pengajuan Beasiswa tidak dapat ditemukan!"},
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

  path '/v1/pengajuan/pengajuan_bantuan/createKuotaBeasiswa' do
    post 'Create Kuota Beasiswa Pengajuan Beasiswa' do
      tags 'Pengajuan Bantuan'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          kuota_beasiswa: {type: :integer, example: 6}
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
                response_message: {type: :string, example: "Pengajuan Beasiswa tidak dapat ditemukan!"},
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

  path '/v1/pengajuan/pengajuan_bantuan/getKuotaBeasiswa' do
    get 'Get Kuota Beasiswa' do
      tags 'Pengajuan Bantuan'
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

  path '/v1/pengajuan/pengajuan_bantuan/getPengajuanBantuan' do
    post 'Get Pengajuan Bantuan Dana' do
      tags 'Pengajuan Bantuan'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
            jenis: {type: :string, example: "Beasiswa"},
            is_pengajuan: {type: :string, example: "true"},
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

  path '/v1/pengajuan/pengajuan_bantuan/getNonBeasiswaByKategori' do
    post 'Get Pengajuan Non Beasiswa By Kategori' do
      tags 'Pengajuan Bantuan'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
            kategori: {type: :string, example: "Medis"},
            is_pengajuan: {type: :string, example: "true"},
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

  path '/v1/pengajuan/pengajuan_bantuan/approvalPengajuanBeasiswa' do
    post 'Approval Pengajuan Baru' do
      tags 'Pengajuan Bantuan'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          id: {type: :integer, example: 763850},
          is_approve: {type: :string, example: "true"},
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
                response_message: {type: :string, example: "Pengajuan Beasiswa tidak dapat ditemukan!"},
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

  path '/v1/pengajuan/pengajuan_bantuan/approvalPengajuanNonBeasiswa' do
    post 'Approval Pengajuan Baru' do
      tags 'Pengajuan Bantuan'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          id: {type: :integer, example: 763850},
          is_approve: {type: :string, example: "true"},
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
                response_message: {type: :string, example: "Pengajuan Beasiswa tidak dapat ditemukan!"},
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

  path '/v1/pengajuan/pengajuan_bantuan/createKehadiranPerkuliahan' do
    post 'Mengunggah kehadiran perkulihaan serta memasukan status kehadiran Perkuliahan' do
      tags 'Pengajuan Bantuan'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          id: {type: :integer, example: "212309"},
          dokumen_kehadiran_perkuliahan: {type: :string, example: "path"},
          status_kehadiran_perkuliahan: {type: :string, example: "TanpaSP"},
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
                response_message: {type: :string, example: "Pengajuan Beasiswa tidak dapat ditemukan!"},
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
  
  path '/v1/pengajuan/pengajuan_bantuan/selectLanjutBeasiswa' do
    post 'Select Penerima Beasiswa' do
      tags 'Pengajuan Bantuan'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
            id: {type: :integer, example: 665846},
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

  path '/v1/pengajuan/pengajuan_bantuan/getTotalCalonPengajuan' do
    post 'Get Pengajuan Non Beasiswa By Kategori' do
      tags 'Pengajuan Bantuan'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
            jenis: {type: :string, example: "Beasiswa"},
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

  path '/v1/pengajuan/pengajuan_bantuan/getDurasiPengajuanBeasiswa' do
    get 'Get Durasi Pengajuan Beasiswa' do
      tags 'Pengajuan Bantuan'
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

  path '/v1/pengajuan/pengajuan_bantuan/getTotalPenerimaBantuan' do
    get 'Get Total All Penerima Bantuan' do
      tags 'Pengajuan Bantuan'
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
