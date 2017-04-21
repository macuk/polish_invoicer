require 'test_helper'

module PolishInvoicer
  class VatTest < Minitest::Test
    def test_valid
      assert Vat.valid?(23)
      assert Vat.valid?(0)
      assert Vat.valid?(-1)
      assert_equal false, Vat.valid?(123)
      assert_equal false, Vat.valid?(-10)
      assert_equal false, Vat.valid?('test')
    end

    def test_zw
      assert Vat.zw?(-1)
      assert_equal false, Vat.zw?(23)
    end

    def test_to_s
      assert_equal '23%', Vat.to_s(23)
      assert_equal '0%', Vat.to_s(0)
      assert_equal 'zw.', Vat.to_s(-1)
    end
  end
end
