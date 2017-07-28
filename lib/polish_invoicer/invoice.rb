module PolishInvoicer
  class Invoice
    AVAILABLE_PARAMS = [
      :number,            # numer faktury (string)
      :create_date,       # data wystawienia faktury (date)
      :trade_date,        # data sprzedaży (date)
      :seller,            # adres sprzedawcy (tablica stringów)
      :seller_nip,        # NIP sprzedawcy (string)
      :buyer,             # adres nabywcy (tablica stringów)
      :buyer_nip,         # NIP nabywcy (string)
      :recipient,         # odbiorca faktury (tablica stringów)
      :item_name,         # nazwa usługi (string)
      :price,             # cena w złotych (float)
      :gross_price,       # znacznik rodzaju ceny (netto/brutto), domyślnie: true (boolean)
      :vat,               # stawka vat, domyślnie: 23 (integer)
      :pkwiu,             # numer PKWiU (string)
      :payment_type,      # rodzaj płatności, domyślnie: 'Przelew' (string)
      :payment_date,      # termin płatności (date)
      :comments,          # uwagi (string lub tablica stringów)
      :paid,              # znacznik opłacenia faktury, domyślnie: true (boolean)
      :footer,            # treść umieszczana w stopce faktury (string)
      :proforma,          # znacznik faktury pro-forma, domyślnie: false (boolean)
      :no_vat_reason,     # podstawa prawna zwolnienia z VAT (string)
      :foreign_buyer,     # nabywcą jest firma spoza Polski, domyślnie: false (boolean)
      :reverse_charge     # faktura z odwrotnym obciążeniem VAT
    ].freeze

    attr_accessor(*AVAILABLE_PARAMS)
    attr_accessor :template_path
    attr_accessor :logger, :wkhtmltopdf_path, :wkhtmltopdf_command

    def initialize(params = {})
      set_defaults
      params.each do |k, v|
        raise "Nierozpoznany parametr #{k}" unless AVAILABLE_PARAMS.include?(k)
        send("#{k}=", v)
      end
      @validator = PolishInvoicer::Validator.new(self)
    end

    def errors
      @validator.errors
    end

    def valid?
      @validator.valid?
    end

    # cena/wartość netto
    def net_value
      return price unless gross_price
      price / (1 + Vat.to_i(vat) / 100.0)
    end

    # kwota VAT
    def vat_value
      (gross_value * Vat.to_i(vat)) / (100.0 + Vat.to_i(vat))
    end

    # cena/wartość brutto
    def gross_value
      return price if gross_price
      price + price * Vat.to_i(vat) / 100.0
    end

    def save_to_html(path)
      validate!
      Writer.new(self).save_to_html(path)
    end

    def save_to_pdf(path)
      validate!
      Writer.new(self).save_to_pdf(path)
    end

    # Wszystkie dane w postaci hash-a
    def to_hash
      Presenter.new(self).data
    end

    private

    def set_defaults
      @gross_price = true
      @vat = 23
      @payment_type = 'Przelew'
      @paid = true
      @proforma = false
      @foreign_buyer = false
      @reverse_charge = false
    end

    def validate!
      return if valid?
      error_messages = errors.map { |k, v| "#{k}: #{v}" }.join(', ')
      raise "Parametry do wystawienia faktury są nieprawidłowe: #{error_messages}"
    end
  end
end
