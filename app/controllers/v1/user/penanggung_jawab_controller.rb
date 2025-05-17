class V1::User::PenanggungJawabController < ApplicationController
  # before_action :
  # GET /admins or /admins.json
  def index
    @admins = User::Admin.all
  end

  def createPenanggungJawab
    admin_registered = PenanggungJawab.where(role: params[:role])
    if admin_registered.present?
      render json: {
        response_code: Constants::ERROR_CODE_VALIDATION,
        response_message: "Admin dengan Role #{params[:role]} sudah terdaftar!"
        }, status: :unprocessable_entity
    else
      admin = PenanggungJawab.new(admin_params)
      rekening = RekeningBank.new(rekening_params)
      rekening.assign_attributes(penanggung_jawab: admin)
      if admin.save and rekening.save
        render json: {
            response_code: Constants::RESPONSE_CREATED, 
            response_message: "Success", 
            data: {admin: admin, rekening: rekening}
            }, status: :created
      else
        render json: {
            response_code: Constants::ERROR_CODE_VALIDATION,
            response_message: {admin: admin.errors.full_messages, rekening: rekening.errors.full_messages}
            }, status: :unprocessable_entity
      end
    end
  end

  def getBankByPenanggungJawab
    admin = PenanggungJawab.penanggung_jawab_jtk_berbagi.first
    if not admin.present?
      rekening_bank = []
    else
      rekening_bank = RekeningBank.where(penanggung_jawab_id: admin.role).first
    end
    return rekening_bank
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin
      @admin = User::Admin.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def admin_params
      params.permit(:nama, :role, :username, :password, :password_confirmation, :nomor_telepon)
    end

    def rekening_params
      params.permit(:nama_bank, :nomor_rekening, :nama_pemilik_rekening)
    end
end
