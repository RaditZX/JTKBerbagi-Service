class V1::User::DonaturController < ApplicationController
  # before_action :
  # GET /donatur or /donatur.json
  def index
    @donatur = User::Donatur.all
  end

  def getTotalDonatur
    donatur = Donatur.donatur_registered
    render json: {
      response_code: Constants::RESPONSE_SUCCESS, 
      response_message: "Success", 
      data: donatur.length
    }, status: :ok
    
  end

  def createDonatur
    @donatur = User::Donatur.new(donatur_params)
    if @donatur.save
      render json: {
          response_code: 201, 
          response_message: "Success", 
          data: @donatur
          }, status: :created
    else
      render json: {
          response_code: 422,
          response_message: @Donatur.errors.full_messages
          }, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_donatur
      @Donatur = User::Donatur.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def donatur_params
      params.permit(:nama, :role, :username, :password, :password_confirmation, :nomor_telepon)
    end
end
