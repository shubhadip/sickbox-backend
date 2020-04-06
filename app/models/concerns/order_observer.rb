module OrderObserver
    extend ActiveSupport::Concern
    included do
        before_save :set_status
    end
    
    private

    def set_status 
        byebug
        if self.id.blank?
            self.status = 3
        end
    end
end