module PolishInvoicer
  class Presenter
    attr_accessor :invoice

    def initialize(invoice)
      @invoice = invoice
      @out = {}
    end

    def data
      copy_available_params
      remove_redundand_params
      copy_additional_params
      format_dates
      format_prices
      format_comments
      format_vat
      @out
    end

    private

    def copy_available_params
      Invoice::AVAILABLE_PARAMS.each do |field|
        @out[field] = @invoice.send(field)
      end
    end

    def remove_redundand_params
      @out.delete(:price)
    end

    def copy_additional_params
      %w[net_value vat_value gross_value exchanged_tax].each do |field|
        @out[field.to_sym] = @invoice.send(field)
      end
    end

    def format_dates
      %w[trade_date create_date payment_date].each do |field|
        v = @invoice.send(field)
        next unless v
        @out[field.to_sym] = v.strftime '%d.%m.%Y'
      end
    end

    def format_prices
      %w[net_value vat_value gross_value exchanged_tax total_to_pay_value paid_value to_pay_value].each do |field|
        v = @invoice.send(field)
        next unless v
        @out[field.to_sym] = sprintf('%02.2f', v).tr('.', ',')
      end
    end

    def format_comments
      @out[:comments] = [@invoice.comments].flatten.compact
    end

    def format_vat
      @out[:vat] = Vat.to_s(@invoice.vat)
    end
  end
end
