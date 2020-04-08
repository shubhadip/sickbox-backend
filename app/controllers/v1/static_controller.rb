class V1::StaticController < ApiController
    def location
        data = STATIC_CONFIG["states"]
        render json: data, status: :ok
    end
end
