class V1::Admin::ProductsController < V1::AdminController
  before_action :set_product, only: %i[show update destroy]
  before_action :set_fields, only: %i[show index]

  def index
    @products =
      Product.includes(set_includes).all.limit(limit).offset(offset).order(
        'id desc'
      )
    if params[:product].present?
      @products = @products.where(products_filter_params)
    end
    render json: @products, status: :ok
  end

  def show; end

  def create
    @product = Product.new(product_params)
    if @product.save
      render json: @product, status: :created
    else
      render_api_error(0, 422, 'error', @product.errors)
    end
  end

  def update
    if @product.update(product_params)
      render json: @product, status: :ok
    else
      render_api_error(0, 422, 'error', @product.errors)
    end
  end

  def search
    if params[:regex].present?
      result =
        Product.where("name like '%#{params[:regex]}%'").order('name asc')
          .limit(100)
    end
    render json: result, status: :ok
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_product
    if params[:id] =~ /[[:alpha:]]/
      @product = Product.find_by(url: params[:id])
    else
      @product = Product.find(params[:id])
    end
  end

  def products_filter
    if params[:product].present?
      @products = @products.where(products_filter_params)
      if params[:product][:term].present?
        @products =
          @products.where(
            'products.name LIKE ?',
            "%#{params[:product][:term]}%"
          )
      end
    end
  end
  # Never trust parameters from the scary internet, only allow the white list through.
  def product_params
    product_params =
      params.require(:product).permit(
        :name,
        :description,
        :url,
        :meta_title,
        :meta_description,
        :meta_keywords,
        :price,
        :mrp,
        :weight,
        :rank,
        :status,
        :avatar
      )
  end

  def products_filter_params
    filter_params =
      params.require(:product).permit(:id, :name, :url, :rank, :status, :avatar)
      attributes = filter_params.to_h || {}
      attributes = attributes.values
      attributes.map do |key, value|
        filter_params[key] = nil if value.to_s.downcase == 'null'
      end
    filter_params
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
    @fields =
      ((all_fields) & Product.attribute_names) | %i[id name status mrp price]
    @additional_fields =
      (
        all_fields &
          Product.reflect_on_all_associations.map { |object| object.name.to_s }
      )
  end
end
