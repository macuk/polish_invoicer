# encoding: utf-8
module PolishInvoicer
  class Presenter
    attr_accessor :invoice

    def initialize(invoice)
      @invoice = invoice
    end

    def data
      out = {}
      Invoice::AVAILABLE_PARAMS.each do |field|
        out[field] = @invoice.send(field)
      end
      %w(net_value vat_value gross_value).each do |field|
        out[field.to_sym] = (@invoice.send(field)).round(2)
      end
      out
    end
  end
end
