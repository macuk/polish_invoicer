# encoding: utf-8
require 'test_helper'

module PolishInvoicer
  class PriceInWordsTest < MiniTest::Unit::TestCase
    def setup
      @piw = PriceInWords.new(1)
    end

    def test_zero
      @piw.price = 0
      assert_equal 'zero zł', @piw.get
    end

    def test_integer
      @piw.price = 123
      assert_equal 'sto dwadzieścia trzy zł', @piw.get
    end

    def test_float
      @piw.price = 123.45
      assert_equal 'sto dwadzieścia trzy i 0,45 zł', @piw.get
    end
  end
end
