class V1::AddressesController < ApiController
    before_action :authenticate_user
    before_action :set_address, only: [:show, :update, :destroy] #:pg_options
    before_action :set_fields, only: [:show, :index]
    # before_action :check_pincode, only: [:show, ] #:pg_options
    before_action :check_address_validation, only: [:update, :create]

    # GET /v1/addresses
    # GET /v1/addresses.json
    def index
      @addresses = Address.active.where(user_id: current_user.id).order('status desc')
    end

    # GET /v1/addresses/1
    # GET /v1/addresses/1.json
    def show
       @current_user = current_user
    end

   # POST /v1/addresses
    # POST /v1/addresses.json
    def create
      @address = Address.new(address_params)
      if @address.save
        render json: @address, status: :created
      else
        render json: @address.errors, status: :unprocessable_entity 
      end
    end
  
    # PATCH/PUT /v1/addresses/1
    # PATCH/PUT /v1/addresses/1.json
    def update
      if (params[:address][:status] ==  'default' || params[:address][:status] ==  'disabled') && params[:address].length == 1
        @address.update(address_params)
      else
        if @address.status != "disabled"
          @old_address = @address
          @address = Address.new(address_params)
          @address.save
          @old_address.update({status: 0}) if @address.errors.blank?
        end
      end
      if @address.errors.blank?
        @addresses = Address.active.where(user_id: current_user.id)
        render :index, status: :ok
      else
        render json: @address.errors, status: :unprocessable_entity
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_address

        @address = Address.where(user: current_user).find(params[:id])
      end
  
      # def check_pincode
      #   render_api_error(31,422) if @address.pincode_service.blank? or @address.pincode_service.inactive? or @address.pincode_service.payment_statuses.blank?
      # end
      
      # Never trust parameters from the scary internet, only allow the white list through.
      def address_params
        address_hash = params.require(:address).permit(:first_name, :last_name,:pincode, :landmark, :address, :mobile, :status, :city, :state, :country, :sub_type, :alternate_mobile)
        address_hash[:user_id] = current_user.id
        if params[:address][:name].present?
          name_details = params[:address][:name].split(" ",2)
          address_hash[:first_name] = name_details.first
          address_hash[:last_name] = name_details.last
        end 
        address_hash
      end
  
      def set_fields
        all_fields = params["fields"].present? ? params["fields"].split(',').collect(&:strip) : []
        @fields = (all_fields & (Address.attribute_names)) | []
      end
  
      def check_address_validation
        unless address_params[:status] ==  'disabled'
          address = Address.new(address_params)
          error = address.validate_name
          error ? render_api_error(0, 422, 'error',error) : []
        end
      end
  end
  