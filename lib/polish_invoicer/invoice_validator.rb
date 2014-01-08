module PolishInvoicer
  class InvoiceValidator
    attr_reader   :errors

    def initialize(invoice)
      @invoice = invoice
      @errors = {}
    end

    def valid?
      true
    end
  end
end
