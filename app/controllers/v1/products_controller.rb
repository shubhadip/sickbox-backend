class V1::ProductsController < ApiController
  before_action :set_product, only: %i[show]
  before_action :set_fields, only: %i[show index]

  def index
    @products =
      Product.includes(set_includes).all.limit(limit).offset(offset).order(
        'id desc'
      )
    if params[:product].present?
      @products = @products.where(product_filter_params)
    end
  end

  def show; end

  private

  def set_product
    if params[:id] =~ /[[:alpha:]]/
      @product = Product.find_by(url: params[:id])
    else
      @product = Product.find(params[:id])
    end
  end

  def set_includes
    include = []
    include
  end

  def product_filter_params
    filter_params = params.require(:product).permit(:id, :status, :price, :mrp)
    filter_params.map do |key, value|
      filter_params[key] = nil if value.to_s.downcase == 'null'
    end
    filter_params
  end

  def set_fields
    all_fields =
      if params['fields'].present?
        params['fields'].split(',').collect(&:strip)
      else
        []
      end
    @fields = (all_fields & Product.attribute_names) | %i[id name status]
    @additional_fields =
      (
        all_fields &
          Product.reflect_on_all_associations.map { |object| object.name.to_s }
      ) |
        []
  end
end
