class V1::Admin::AddressesController < ApplicationController #V1::AdminController
    before_action :set_address, only: [:show, :update, :destroy]
  
    # GET /v1/admin/addresses
    # GET /v1/admin/addresses.json
    def index
      @addresses = Address.where(user_id: params[:user_id])
    end
  
    # GET /v1/admin/addresses/1
    # GET /v1/admin/addresses/1.json
    def show
    end
  
    # POST /v1/admin/addresses
    # POST /v1/admin/addresses.json
    def create
      @address = Address.new(address_params)
      if @address.save
        render json: @address, status: :created
      else
        render json: @address.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /v1/admin/addresses/1
    # PATCH/PUT /v1/admin/addresses/1.json
    def update
      if @address.update(address_params)
        render json: @address, status: :ok
      else
        render json: @address.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /v1/admin/addresses/1
    # DELETE /v1/admin/addresses/1.jsons
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_address
        @address = Address.where(user_id: params[:user_id]).find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def address_params
        params.require(:address).permit(:user_id, :first_name, :last_name, :pincode, :landmark, :address, :mobile, :status, :city, :state, :country)
      end
  end
  