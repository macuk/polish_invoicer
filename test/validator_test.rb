require 'test_helper'

module PolishInvoicer
  class ValidatorTest < MiniTest::Unit::TestCase
    require 'ostruct'

    def setup
      @invoice = OpenStruct.new
    end

    def check_error(field, value=nil)
      @invoice.send("#{field}=", value)
      v = Validator.new(@invoice)
      v.valid?
      assert v.errors[field]
    end

    def check_ok(field, value=nil)
      @invoice.send("#{field}=", value)
      v = Validator.new(@invoice)
      v.valid?
      assert_nil v.errors[field]
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

    def test_proforma_could_not_be_paid
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

    def test_seller_and_buyer_nip_presence
      check_error(:seller_nip)
      check_ok(:buyer_nip)
      check_ok(:seller_nip, '123')
      check_ok(:buyer_nip, '123')
    end

    def check_dates_ok(create_date, trade_date, msg=nil)
      @invoice.create_date = Date.parse(create_date)
      @invoice.trade_date = Date.parse(trade_date)
      v = Validator.new(@invoice); v.valid?
      assert_nil v.errors[:create_date], msg
    end

    def check_dates_error(create_date, trade_date, msg=nil)
      @invoice.create_date = Date.parse(create_date)
      @invoice.trade_date = Date.parse(trade_date)
      v = Validator.new(@invoice); v.valid?
      assert v.errors[:create_date], msg
    end

    # data wystawienia max 30 dni przed wykonaniem usługi
    def test_create_and_trade_date_correlation_before_trade
      check_dates_ok('2014-01-01', '2014-01-01', 'B1')
      check_dates_ok('2014-01-01', '2014-01-31', 'B2')
      check_dates_error('2014-01-01', '2014-02-01', 'B3')
      check_dates_ok('2014-01-02', '2014-02-01', 'B4')
    end

    # data wystawienie max 15 dnia następnego miesiąca po wykonaniu usługi
    def test_create_and_trade_date_correlation_after_trade
      check_dates_ok('2014-02-15', '2014-01-01', 'A1')
      check_dates_error('2014-02-16', '2014-01-01', 'A2')
      check_dates_error('2014-02-16', '2014-01-02', 'A3')
      check_dates_error('2014-02-16', '2014-01-31', 'A4')
      check_dates_ok('2014-02-15', '2014-01-31', 'A5')
      check_dates_ok('2014-03-15', '2014-02-15', 'A6')
    end

    def test_no_vat_reason_presence
      @invoice.vat = 23
      v = Validator.new(@invoice); v.valid?
      assert_nil v.errors[:no_vat_reason]
      @invoice.vat = -1
      v = Validator.new(@invoice); v.valid?
      assert v.errors[:no_vat_reason]
      @invoice.no_vat_reason = 'reason'
      v = Validator.new(@invoice); v.valid?
      assert_nil v.errors[:no_vat_reason]
    end
  end
end
