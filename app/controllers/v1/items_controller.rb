class V1::ItemsController < ApiController
    before_action :set_item, only: %i[show]
    before_action :set_fields, only: %i[show index]
  
    def index
      @items =
        Item.includes(set_includes).all.limit(limit).offset(offset).order(
          'id desc'
        )
      if params[:item].present?
        @items = @items.where(item_filter_params)
      end
    end
  
    def show; end
  
    private
  
    def set_item
        @item = Item.find(params[:id])
    end
  
    def set_includes
      include = []
      include
    end
  
    def item_filter_params
      filter_params = params.require(:item).permit(:id, :title, :description, :imageUrl, :buttonText, :product_id)
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
      @fields = (all_fields & Item.attribute_names) | %i[id name status]
      @additional_fields =
        (
          all_fields &
            Item.reflect_on_all_associations.map { |object| object.name.to_s }
        ) |
          []
    end
end
