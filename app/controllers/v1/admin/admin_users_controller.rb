class V1::Admin::AdminUsersController < V1::AdminController
  before_action :set_admin_user, only: %i[show update destroy]
  before_action :set_fields, only: %i[show index]

  # GET /admin_users
  # GET /admin_users.json
  def index
    @admin_users = AdminUser.includes(set_includes).all
    if params['status'] == 'enabled'
      @admin_users = @admin_users.where(enable: true)
    end
    @admin_users = @admin_users.order(order_by).limit(limit).offset(offset)
  end

  # GET /admin_users/1
  # GET /admin_users/1.json
  def show; end

  # POST /admin_users
  # POST /admin_users.json
  def create
    @admin_user = AdminUser.new(admin_user_params)
    if @admin_user.save
      render json: @admin_user, status: :created
    else
      render json: @admin_user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /admin_users/1
  # PATCH/PUT /admin_users/1.json
  def update
    if @admin_user.update(admin_user_params)
      render json: @admin_user, status: :ok
    else
      render json: @admin_user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /admin_users/1
  # DELETE /admin_users/1.json
  def destroy
    @admin_user.destroy
    respond_to { |format| format.json { head :no_content } }
  end

  def get_static_data
    data = {}
    data[:departments] = []
    APP_CONFIG['departments'].each do |department_id, department|
      department.map do |department_name, designations|
        data[:departments] <<
          {
            id: department_id, name: department_name, designation: designations
          }
      end
    end
    render json: data
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_admin_user
    @admin_user = AdminUser.find(params[:id]) if params[:id].present?
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def admin_user_params
    params.require(:admin_user).permit(
      :first_name,
      :last_name,
      :email,
      :personal_email,
      :password,
      :designation,
      :department,
      :enable,
      :can_login,
      :can_sales_login,
      :mobile,
      :mobile_other,
      :office_location,
      :employee_code
    )
  end

  def set_includes
    include = []
    include
  end

  def set_fields
    all_fields =
      if params['fields'].present?
        params['fields'].split(',').collect(&:strip)
      else
        []
      end
    @fields = (all_fields & AdminUser.attribute_names) | %i[id]
    @additional_fields =
      (
        all_fields &
          AdminUser.reflect_on_all_associations.map do |object|
            object.name.to_s
          end
      )
  end
end
