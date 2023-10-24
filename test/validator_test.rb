# frozen_string_literal: true

require 'test_helper'

module PolishInvoicer
  class ValidatorTest < Minitest::Test
    require 'ostruct'

    def setup
      @invoice = OpenStruct.new
    end

    def test_number_validation
      check_error(:number)
      check_ok(:number, '1/2014')
    end

    def test_create_date_validation
      check_error(:create_date)
      check_error(:create_date, 'test')
      check_error(:create_date, 100)
      check_error(:create_date, '2014-01-01')
      check_ok(:create_date, Date.parse('2014-01-01'))
    end

    def test_trade_date_validation
      check_error(:trade_date)
      check_error(:trade_date, 'test')
      check_error(:trade_date, 100)
      check_error(:trade_date, '2014-01-01')
      check_ok(:trade_date, Date.parse('2014-01-01'))
    end

    def test_seller_validation
      check_error(:seller)
      check_error(:seller, 'test')
      check_ok(:seller, ['Jan Nowak', 'Gdynia'])
    end

    def test_buyer_validation
      check_error(:buyer)
      check_error(:buyer, 'test')
      check_ok(:buyer, ['Jan Nowak', 'Gdynia'])
    end

    def test_item_name_validation
      check_error(:item_name)
      check_ok(:item_name, 'test')
    end

    def test_price_validation
      check_error(:price)
      check_error(:price, 'test')
      check_error(:price, '100')
      check_error(:price, -10)
      check_ok(:price, 19.99)
    end

    def test_price_paid_validation
      @invoice.price = 200
      check_ok(:price_paid)
      check_error(:price_paid, 'test')
      check_error(:price_paid, '100')
      check_error(:price_paid, -10)
      check_error(:price_paid, 300)
      check_ok(:price_paid, 19.99)
    end

    def test_gross_price_validation
      check_error(:gross_price)
      check_error(:gross_price, 'test')
      check_ok(:gross_price, true)
      check_ok(:gross_price, false)
    end

    def test_vat_validation
      check_error(:vat)
      check_error(:vat, '23')
      check_error(:vat, 100)
      check_ok(:vat, 8)
      check_ok(:vat, -1)
    end

    def test_payment_type_validation
      check_error(:payment_type)
      check_ok(:payment_type, 'Przelew')
    end

    def test_payment_date_validation
      check_error(:payment_date)
      check_error(:payment_date, 'test')
      check_error(:payment_date, 100)
      check_error(:payment_date, '2014-01-01')
      check_ok(:payment_date, Date.parse('2014-01-01'))
    end

    def test_paid_validation
      check_error(:paid)
      check_error(:paid, 'test')
      check_ok(:paid, true)
      check_ok(:paid, false)
    end

    def test_proforma_validation
      check_error(:proforma)
      check_error(:proforma, 'test')
      check_ok(:proforma, true)
      check_ok(:proforma, false)
    end

    def test_proforma_not_paid
      @invoice.paid = true
      @invoice.proforma = true
      v = Validator.new(@invoice)
      v.valid?

      assert v.errors[:paid]
      @invoice.paid = false
      v = Validator.new(@invoice)
      v.valid?

      assert_nil v.errors[:paid]
    end

    def test_nip_presence
      check_error(:seller_nip)
      check_ok(:buyer_nip)
      check_ok(:seller_nip, '123')
      check_ok(:buyer_nip, '123')
    end

    def test_no_vat_reason_presence
      @invoice.vat = 23
      v = Validator.new(@invoice)
      v.valid?

      assert_nil v.errors[:no_vat_reason]
      @invoice.vat = -1
      v = Validator.new(@invoice)
      v.valid?

      assert v.errors[:no_vat_reason]
      @invoice.no_vat_reason = 'reason'
      v = Validator.new(@invoice)
      v.valid?

      assert_nil v.errors[:no_vat_reason]
    end

    def test_create_and_payment_date
      @invoice.create_date = Date.parse('2018-04-10')
      @invoice.payment_date = Date.parse('2018-04-01')
      v = Validator.new(@invoice)
      v.valid?

      assert v.errors[:payment_date]
      @invoice.payment_date = Date.parse('2018-04-17')
      v = Validator.new(@invoice)
      v.valid?

      assert_nil v.errors[:payment_date]
    end

    def test_currency
      @invoice.currency = nil
      v = Validator.new(@invoice)
      v.valid?

      assert v.errors[:currency]
      @invoice.currency = 'XYZ'
      v = Validator.new(@invoice)
      v.valid?

      assert v.errors[:currency]
      @invoice.currency = 'EUR'
      v = Validator.new(@invoice)
      v.valid?

      refute v.errors[:currency]
    end

    def test_exchange_rate
      @invoice.exchange_rate = nil
      v = Validator.new(@invoice)
      v.valid?

      assert v.errors[:exchange_rate]
      @invoice.exchange_rate = 4.1234
      v = Validator.new(@invoice)
      v.valid?

      refute v.errors[:exchange_rate]
    end

    def test_lang
      v = Validator.new(@invoice)
      v.valid?

      refute v.errors[:lang]
      @invoice.lang = 'xx'
      v = Validator.new(@invoice)
      v.valid?

      assert v.errors[:lang]
      @invoice.lang = 'en'
      v = Validator.new(@invoice)
      v.valid?

      refute v.errors[:lang]
    end

    private

    def check_error(field, value = nil)
      @invoice.send("#{field}=", value)
      v = Validator.new(@invoice)
      v.valid?

      assert v.errors[field]
    end

    def check_ok(field, value = nil)
      @invoice.send("#{field}=", value)
      v = Validator.new(@invoice)
      v.valid?

      assert_nil v.errors[field]
    end
  end
end
