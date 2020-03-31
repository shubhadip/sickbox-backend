class V1::SubscribersController < ApiController
  before_action :set_subscriber, only: %i[show update destroy]
  before_action :set_fields, only: %i[show index]

  # GET /subscribers
  # GET /subscribers.json
  def index
    @subscribers = Subscriber.includes(set_includes).all
    @subscribers = @subscribers.order(order_by).limit(limit).offset(offset)
  end

  # GET /subscribers/1
  # GET /subscribers/1.json
  def show; end

  # POST /subscribers
  # POST /subscribers.json
  def create
    @subscriber = Subscriber.new(subscriber_params)
    if @subscriber.save
      render json: @subscriber, status: :created
    else
      render json: @subscriber.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /subscribers/1
  # PATCH/PUT /subscribers/1.json
  def update
    if @subscriber.update(subscriber_params)
      render json: @subscriber, status: :ok
    else
      render json: @subscriber.errors, status: :unprocessable_entity
    end
  end

  # DELETE /subscribers/1
  # DELETE /subscribers/1.json
  def destroy
    @subscriber.destroy
    respond_to { |format| format.json { head :no_content } }
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_subscriber
    @subscriber = Subscriber.find(params[:id]) if params[:id].present?
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def subscriber_params
    params.require(:subscriber).permit(
      :email,
      :device_type
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
    @fields = (all_fields & Subscriber.attribute_names) | %i[id]
    @additional_fields =
      (
        all_fields &
        Subscriber.reflect_on_all_associations.map do |object|
            object.name.to_s
        end
      )
  end
end
