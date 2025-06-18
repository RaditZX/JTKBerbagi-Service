class ApplicationController < ActionController::API
  def role
    header = request.authorization
    @decoded = JsonWebToken.decode(header)
    @current_admin = PenanggungJawab.find(@decoded[:admin_id]).role
    return @current_admin
  end
  
  def authorize_request
      header = request.headers['Authorization']
      header = header.split(' ').last if header
      begin
        @decoded = JsonWebToken.decode(header)
        @current_admin = PenanggungJawab.find(@decoded[:admin_id])
        # rescue ActiveRecord::RecordNotFound => e
        #   render json: { errors: e.message + '. admin yang anda cari tidak dapat ditemukan!' }, status: :unauthorized
        rescue JWT::DecodeError => e
          if e.message.match(/Nil/)
            render json: { 
              response_code: 401, 
              response_message: 'Token Dibutuhkan, Silahkan login terlebih dahulu untuk mendapatkan tokennya!' 
              }, status: :unauthorized
          else
            render json: { 
              response_code: 401, 
              response_message: 'Token salah, Silahkan periksa kembali!' 
              }, status: :unauthorized
          end
      end
  end

  def render_success_response(response_code, data, status)
    render json: {
      response_code: response_code,
      response_message: "Success!",
      data: data
    }, status: status
  end

  def render_error_response(message)
    render json: {
      response_code: Constants::ERROR_CODE_VALIDATION,
      response_message: message
    }, status: :unprocessable_entity
  end
end
  