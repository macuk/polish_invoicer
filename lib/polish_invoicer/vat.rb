module PolishInvoicer
  class Vat
    def self.rates
      [23, 8, 5, 0, -1] # -1 oznacza zwolniony z VAT
    end

    def self.valid?(rate)
      rates.include?(rate)
    end

    # Czy stawka VAT to "zwolniony"?
    def self.zw?(rate)
      rate == -1
    end

    def self.to_s(rate)
      hash.invert[rate]
    end

    # Potrzebne do obliczeń netto/vat/brutto
    def self.to_i(rate)
      rate != -1 ? rate : 0
    end

    private

    def self.hash
      h = {}
      rates.each do |r|
        name = "#{r}%"
        name = 'zw.' if r == -1
        h[name] = r
      end
      h
    end
  end
end
