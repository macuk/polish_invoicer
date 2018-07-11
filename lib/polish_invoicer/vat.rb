module PolishInvoicer
  class Vat
    def self.rates
      (0..27)
    end

    def self.valid?(rate)
      return true if zw?(rate)
      rates.include?(rate)
    end

    # Czy stawka VAT to "zwolniony"?
    def self.zw?(rate)
      rate == -1 # -1 oznacza zwolniony z VAT
    end

    def self.to_s(rate)
      return 'zw.' if zw?(rate)
      "#{rate}%"
    end

    # Potrzebne do obliczeń netto/vat/brutto
    def self.to_i(rate)
      zw?(rate) ? 0 : rate
    end
  end
end
