# encoding: utf-8
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
      @out
    end

    protected
      def copy_available_params
        Invoice::AVAILABLE_PARAMS.each do |field|
          @out[field] = @invoice.send(field)
        end
      end

      def remove_redundand_params
        @out.delete(:price)
      end

      def copy_additional_params
        %w(net_value vat_value gross_value).each do |field|
          @out[field.to_sym] = @invoice.send(field)
        end
      end

      def format_dates
        %w(trade_date create_date payment_date).each do |field|
          v = @invoice.send(field)
          next unless v
          @out[field.to_sym] = v.strftime "%d.%m.%Y"
        end
      end

      def format_prices
        %w(net_value vat_value gross_value).each do |field|
          v = @invoice.send(field)
          next unless v
          @out[field.to_sym] = sprintf("%02.2f", v).gsub('.', ',')
        end
      end

      def format_comments
        @out[:comments] = [@invoice.comments].flatten.compact
      end
  end
end
