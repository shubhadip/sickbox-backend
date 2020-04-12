class OrderProduct < ApplicationRecord
    belongs_to :order
    belongs_to :product
    validates :product_id, :quantity, presence: true
    before_save :add_price

    def discount
        return 0
    end

    def amount_exclusive_of_tax
        (taxable_amount - tax.to_f)
    end

    def get_tax_percentage_for_product
        tax_percentage = 0.06
        tax_percentage
    end

    def tax
        ((taxable_amount / (1+get_tax_percentage_for_product) ).round(2) * get_tax_percentage_for_product).round(2)
    end

    def taxable_amount
        self.product.price
    end

    def rate
        tax_precentage =  get_tax_percentage_for_product 
        @rate = ((self.price - (discount||0))/(1+ tax_precentage)).round(2)
    end

    def amount
        @amount = (self.quantity*self.price)
    end

    def shipping_cod_charges
        order.cod_money + order.shipping_money
    end

    def get_gst_amount_by_percentage(amount,percentage)
        percentage = percentage/100
        ( (amount / (1+percentage) ) * percentage)
    end

    def gst_product_net_amount
        return 0 if product_sale_amount <= 0
        product_sale_amount - get_gst_amount_by_percentage(product_sale_amount,gst_percentage)
    end

    def gst_cod_net_amount
        return 0 if product_sale_amount+order.shipping_money+order.cod_money <= 0
        order.cod_money - get_gst_amount_by_percentage(order.cod_money,gst_percentage)
    end

    def gst_shipping_net_amount
        return 0 if product_sale_amount+order.shipping_money <= 0
        order.shipping_money - get_gst_amount_by_percentage(order.shipping_money,gst_percentage)
    end

    def gst_tax
        total_tax = get_gst_amount_by_percentage(gst_taxable_amount,gst_percentage)
        tax_values = order.address.state.downcase == 'maharashtra' ? cgst_sgst_tax(total_tax,gst_percentage) : igst_tax(total_tax,gst_percentage)
    end

    def gst_percentage
        tax = 12
        tax.to_f
    end

    def igst_tax(total_tax,percentage)
        {igst_amount:total_tax,igst_percentage:percentage,cgst_amount:0,cgst_percentage:0,sgst_amount:0,sgst_percentage:0}
    end

    def cgst_sgst_tax(total_tax,percentage)
        cgst_percentage = cgst_or_sgst_tax_percentage("cgst")
        sgst_percentage = cgst_or_sgst_tax_percentage("sgst")
        {cgst_amount:total_tax*cgst_percentage,cgst_percentage:cgst_percentage*percentage,sgst_amount:total_tax*sgst_percentage,sgst_percentage:sgst_percentage*percentage,igst_amount:0,igst_percentage:0}
    end

    def cgst_or_sgst_tax_percentage(type)
        (APP_CONFIG["#{type}_tax_percentage_ratio"].to_f/100)
    end

    def product_sale_amount
        (self.price - (self.discount||0) )
    end

    def gst_taxable_amount
        product_sale_amount + shipping_cod_charges
    end

    def shipping_cod_charges
        order.cod_money + order.shipping_money
    end


    private

    def add_price
        if self.price.blank? && self.id.blank?
            self.price = Product.find(self.product_id).price
            self.cgst_percentage = self.gst_tax[:cgst_percentage]
            self.cgst_amount = self.gst_tax[:cgst_amount]
            self.sgst_percentage = self.gst_tax[:sgst_percentage]
            self.sgst_amount = self.gst_tax[:sgst_amount]
            self.igst_percentage = self.gst_tax[:igst_percentage]
            self.igst_amount = self.gst_tax[:igst_amount]
        end
    end

end