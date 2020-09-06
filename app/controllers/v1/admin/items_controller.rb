class V1::Admin::ItemsController < V1::AdminController
  before_action :set_item, only: %i[show update destroy]
  before_action :set_fields, only: %i[show index]

  def index
    @items =
      Item.includes(set_includes).all.limit(limit).offset(offset).order(
        'id desc'
      )
    if params[:item].present?
      @items = @items.where(items_filter_params)
    end
  end

  def show; end

  def create
    @item = Item.new(item_params)
    if @item.save
      render json: @item, status: :created
    else
      render_api_error(0, 422, 'error', @item.errors)
    end
  end

  def update
    if @item.update(item_params)
      render json: @item, status: :ok
    else
      render_api_error(0, 422, 'error', @item.errors)
    end
  end

  def search
    if params[:regex].present?
      result =
        Item.where("title like '%#{params[:regex]}%'").order('title asc')
          .limit(100)
    end
    render json: result, status: :ok
  end
  
  private

  # Use callbacks to share common setup or constraints between actions.
  def set_item
      @item = Item.find(params[:id])
  end

  def item_filter
    if params[:item].present?
      @items = @items.where(items_filter_params)
      if params[:item][:term].present?
        @items =
          @items.where(
            'items.title LIKE ?',
            "%#{params[:item][:term]}%"
          )
      end
    end
  end
  # Never trust parameters from the scary internet, only allow the white list through.
  def item_params
    item_params =
      params.require(:item).permit(:title,  :description, :imageUrl, :product_id, :buttonText, images: [])
      item_params
  end

  def items_filter_params
    filter_params =
      params.require(:item).permit(:id, :title, :description, :imageUrl, :buttonText, :product_id, images: [] )
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
      ((all_fields) & Item.attribute_names) | %i[id title ]
    @additional_fields =
      (
        all_fields &
          Item.reflect_on_all_associations
      )
  end
end
