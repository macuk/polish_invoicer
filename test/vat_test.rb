# frozen_string_literal: true

require 'test_helper'

module PolishInvoicer
  class VatTest < Minitest::Test
    def test_valid
      assert Vat.valid?(23)
      assert Vat.valid?(27)
      assert Vat.valid?(2)
      assert Vat.valid?(5.5)
      assert Vat.valid?(4.8)
      assert Vat.valid?(0)
      assert Vat.valid?(-1)
      refute Vat.valid?(123)
      refute Vat.valid?(-10)
      refute Vat.valid?('test')
      refute Vat.valid?('2,1')
      refute Vat.valid?('2.1')
    end

    def test_zw
      assert Vat.zw?(-1)
      refute Vat.zw?(23)
    end

    def test_to_s
      assert_equal '23%', Vat.to_s(23)
      assert_equal '5.5%', Vat.to_s(5.5)
      assert_equal '0%', Vat.to_s(0)
      assert_equal 'zw.', Vat.to_s(-1)
    end

    def test_to_i
      assert_equal 0, Vat.to_i(-1)
      assert_in_delta(5.5, Vat.to_i(5.5))
      assert_equal 20, Vat.to_i(20)
    end
  end
end
