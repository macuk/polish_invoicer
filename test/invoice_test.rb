require 'test_helper'

module PolishInvoicer
  class InvoiceTest < Minitest::Test
    def test_init
      i = Invoice.new
      assert i.is_a?(Invoice)
    end

    def test_set_available_param
      i = Invoice.new(number: '1/2014')
      assert_equal '1/2014', i.number
    end

    def test_set_unavailable_param
      assert_raises(RuntimeError) { Invoice.new(test: 'abc') }
    end

    def test_validation_delegation
      i = Invoice.new
      assert_equal false, i.valid?
      assert i.errors[:number]
      i.number = '1/2014'
      i.valid?
      assert_nil i.errors[:number]
    end

    def test_net_value
      i = Invoice.new(price: 123.45, gross_price: false)
      i.vat = 23
      assert_in_delta 123.45, i.net_value, 0.01

      i.gross_price = true
      i.vat = 23
      assert_in_delta 100.37, i.net_value, 0.01
      i.vat = 5.5
      assert_in_delta 117.01, i.net_value, 0.01
      i.vat = 0
      assert_in_delta 123.45, i.net_value, 0.01
      i.vat = -1
      assert_in_delta 123.45, i.net_value, 0.01

      i.gross_price = false
      i.vat = 0
      assert_in_delta 123.45, i.net_value, 0.01
      i.vat = -1
      assert_in_delta 123.45, i.net_value, 0.01
      i.vat = 5.5
      assert_in_delta 123.45, i.net_value, 0.01
    end

    def test_vat_value
      i = Invoice.new(price: 123.45, gross_price: false)
      i.vat = 23
      assert_in_delta 28.39, i.vat_value, 0.01
      i.vat = 5.5
      assert_in_delta 6.79, i.vat_value, 0.01

      i.gross_price = true
      i.vat = 23
      assert_in_delta 23.08, i.vat_value, 0.01
      i.vat = 5.5
      assert_in_delta 6.44, i.vat_value, 0.01
      i.vat = 0
      assert_equal 0.00, i.vat_value
      i.vat = -1
      assert_equal 0.00, i.vat_value
    end

    def test_gross_value
      i = Invoice.new(price: 123.45, gross_price: false)
      i.vat = 23
      assert_in_delta 151.84, i.gross_value, 0.01

      i.gross_price = true
      i.vat = 23
      assert_in_delta 123.45, i.gross_value, 0.01
      i.vat = 5.5
      assert_in_delta 123.45, i.gross_value, 0.01
      i.vat = 0
      assert_in_delta 123.45, i.gross_value, 0.01
      i.vat = -1
      assert_in_delta 123.45, i.gross_value, 0.01

      i.gross_price = false
      i.vat = 5.5
      assert_in_delta 130.24, i.gross_value, 0.01
      i.vat = 0
      assert_in_delta 123.45, i.gross_value, 0.01
      i.vat = -1
      assert_in_delta 123.45, i.gross_value, 0.01
    end

    def test_defaults
      i = Invoice.new
      assert i.gross_price
      assert 23, i.vat
      assert 'Przelew', i.payment_type
      assert i.paid
      assert_equal false, i.proforma
    end

    def test_raise_when_save_to_html_and_not_valid
      i = Invoice.new
      assert_raises(RuntimeError) { i.save_to_html('/tmp/test.html') }
    end

    def test_raise_when_save_to_pdf_and_not_valid
      i = Invoice.new
      assert_raises(RuntimeError) { i.save_to_pdf('/tmp/test.pdf') }
    end

    def test_save_to_html
      i = create_valid_invoice
      path = '/tmp/test.html'
      i.save_to_html(path)
      assert File.exist?(path)
      File.unlink(path)
    end

    def test_save_to_pdf
      i = create_valid_invoice
      path = '/tmp/test.pdf'
      i.save_to_pdf(path)
      assert File.exist?(path)
      File.unlink(path)
    end

    def test_to_hash
      i = Invoice.new(price: 123.45, gross_price: false)
      h = i.to_hash
      assert h[:paid] # default
      assert_equal false, h[:gross_price] # params
      assert_equal '123,45', h[:net_value] # presenter
    end
  end
end
