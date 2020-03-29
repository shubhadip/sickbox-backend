class V1::ProductsController < ApiController
    before_action :set_product, only: [:show]
    before_action :set_fields, only: [:show, :index]

    def index
        @products = Product.includes(set_includes).all.limit(limit).offset(offset).order("id desc")
        @products = @products.where(product_filter_params) if params[:product].present?
    end

    def show
    end

    private

      def set_product
        if params[:id] =~ /[[:alpha:]]/
          @product = Product.find_by(:url => params[:id])
        else
          @product = Product.find(params[:id])
        end
      end

      def set_includes
        include = []
        include
      end

      def product_filter_params
        filter_params = params.require(:product).permit(:id)
        filter_params.map{ |key, value| filter_params[key] = nil if value.to_s.downcase == "null"}
        filter_params
      end

      def set_fields
        all_fields = params["fields"].present? ? params["fields"].split(',').collect(&:strip) : []
        @fields = (all_fields & Product.attribute_names) | [:id, :name, :status]
        @additional_fields = (all_fields & Product.reflect_on_all_associations.map {|object| object.name.to_s}) | []
      end
  end
