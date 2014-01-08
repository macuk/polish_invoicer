# encoding: utf-8
module PolishInvoicer
  class PriceInWords
    attr_accessor :price

    def initialize(price)
      @price = price
    end

    def get
      zl = @price.to_i
      gr = ((@price - zl) * 100).to_i
      out = PolishNumber.translate(zl)
      out << " i 0,#{gr}" if gr > 0
      out << " zł"
    end
  end
end
