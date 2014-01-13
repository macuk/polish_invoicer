# encoding: utf-8
module PolishInvoicer
  class Invoice
    AVAILABLE_PARAMS = [
      :number,            # numer faktury (string)
      :create_date,       # data wystawienia faktury (date)
      :trade_date,        # data sprzedaży (date)
      :seller,            # adres i nip sprzedawcy (tablica stringów)
      :buyer,             # adres i nip nabywcy (tablica stringów)
      :item_name,         # nazwa usługi (string)
      :price,             # cena w złotych (float)
      :gross_price,       # znacznik rodzaju ceny (netto/brutto), domyślnie: true (boolean)
      :vat,               # stawka vat, domyślnie: 23 (integer)
      :pkwiu,             # numer PKWiU (string)
      :created_by,        # osoba wystawiająca fakturę (string)
      :payment_type,      # rodzaj płatności, domyślnie: 'Przelew' (string)
      :payment_date,      # termin płatności (date)
      :comments,          # uwagi (string lub tablica stringów)
      :paid,              # znacznik opłacenia faktury, domyślnie: true (boolean)
      :footer,            # treść umieszczana w stopce faktury (string)
    ]

    attr_accessor *AVAILABLE_PARAMS

    def initialize(params={})
      set_defaults
      params.each do |k, v|
        raise 'Nierozpoznany parametr' unless AVAILABLE_PARAMS.include?(k)
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

    def price_in_words
      PriceInWords.new(gross_value).get
    end

    # cena/wartość netto
    def net_value
      return price unless gross_price
      (price / (1 + Vat.to_i(vat)/100.0)).round(2)
    end

    # kwota VAT
    def vat_value
      ((gross_value * Vat.to_i(vat)) / (100.0 + Vat.to_i(vat))).round(2)
    end

    # cena/wartość brutto
    def gross_value
      return price if gross_price
      (price + price * Vat.to_i(vat)/100.0).round(2)
    end

    def save_to_file(path)
      raise 'Parametry do wystawienia faktury są nieprawidłowe' unless valid?
      InvoiceSaver.new(self).save_to_file(path)
    end

    # Wszystkie dane w postaci hash-a
    def to_hash
      out = {}
      AVAILABLE_PARAMS.each do |field|
        out[field] = send(field)
      end
      %w(price_in_words net_value vat_value gross_value).each do |field|
        out[field.to_sym] = send(field)
      end
      out
    end

    protected
      def set_defaults
        @gross_price = true
        @vat = 23
        @payment_type = 'Przelew'
        @paid = true
      end
  end
end
