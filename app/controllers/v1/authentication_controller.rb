class V1::AuthenticationController < ApplicationController
    def loginPenanggungJawab
        admin = PenanggungJawab.where(username: params[:username]).first
        if admin.blank?
          render json: { 
            response_code: 401, 
            response_message: 'email salah!, silahkan periksa kembali' 
            }, status: :unauthorized
        else
            if admin.authenticate(params[:password])
                token = JsonWebToken.encode(admin_id: admin.id)
                time = Time.now + 24.hours.to_i
                render json: { 
                  response_code: Constants::RESPONSE_SUCCESS, 
                  response_message:'Success!', 
                  data: {admin: admin, token_access: token, exp: time.strftime("%m-%d-%Y %H:%M")} 
                  }, status: :ok
            else
                render json: { 
                  response_code: Constants::ERROR_CODE_HEADER_INVALID, 
                  response_message: 'Password salah!, silahkan periksa kembali'
                  }, status: :unauthorized
            end
        end
    end

    def loginDonatur
        donatur = Donatur.where(nomor_telepon: params[:nomor_telepon]).first
        if donatur.blank?
          render json: { 
            response_code: 401, 
            response_message: 'Nomor telepon salah!, silahkan periksa kembali' 
            }, status: :unauthorized
        else
            if donatur.authenticate(params[:password])
                token = JsonWebToken.encode(donatur_id: donatur.id)
                time = Time.now + 24.hours.to_i
                render json: { 
                  response_code: Constants::RESPONSE_SUCCESS, 
                  response_message:'Success!', 
                  data: {admin: donatur, token_access: token, exp: time.strftime("%m-%d-%Y %H:%M")} 
                  }, status: :ok
            else
                render json: { 
                  response_code: Constants::ERROR_CODE_HEADER_INVALID, 
                  response_message: 'Password salah!, silahkan periksa kembali'
                  }, status: :unauthorized
            end
        end
    end


    private

    def login_penanggung_jawab_params
        params.permit(:username, :password)
    end

    def login_donatur_params
        params.permit(:nomor_telepon, :password)
    end
end
