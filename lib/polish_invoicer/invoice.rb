module PolishInvoicer
  class Invoice
    AVAILABLE_PARAMS = [
      :number,            # invoice number (string)
      :create_date,       # creation date (date)
      :trade_date,        # trading date (date)
      :seller,            # seller name, address, nip (array of strings)
      :buyer,             # buyer name, address, nip (array of strings)
      :item_name,         # invoice title, service name (string)
      :price,             # price in pln (float)
      :gross_price,       # true if price is gross value (boolean)
      :vat,               # vat rate (integer)
      :pkwiu,             # PKWiU number (string)
      :created_by,        # invoice creator name and surname (string)
      :payment_type,      # type of payment (string)
      :payment_date,      # date of payment (date)
      :comments,          # comments (array of string)
      :paid,              # true if invoice was paid (boolean)
    ]

    attr_accessor *AVAILABLE_PARAMS

    def initialize(params={})
      params.each do |k, v|
        raise unless AVAILABLE_PARAMS.include?(k)
        send("#{k}=", v)
      end
      @validator = InvoiceValidator.new(self)
    end

    def errors
      @validator.errors
    end

    def valid?
      @validator.valid?
    end

    def save_to_file(path)
      InvoiceSaver.new(self).save_to_file(path)
    end
  end
end
