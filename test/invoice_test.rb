# encoding: utf-8
require 'test_helper'

module PolishInvoicer
  class InvoiceTest < MiniTest::Unit::TestCase
    def test_init
      i = Invoice.new
      assert i.is_a?(Invoice)
    end

    def test_set_available_param
      i = Invoice.new({number: '1/2014'})
      assert_equal '1/2014', i.number
    end

    def test_set_unavailable_param
      assert_raises(RuntimeError) { i = Invoice.new({test: 'abc'}) }
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
      i = Invoice.new({price: 123.45, gross_price: false, vat: 23})
      assert_equal 123.45, i.net_value
      i.gross_price = true
      assert_equal 100.37, i.net_value
      i.vat = 0
      assert_equal 123.45, i.net_value
      i.vat = -1
      assert_equal 123.45, i.net_value
      i.gross_price = false
      i.vat = 0
      assert_equal 123.45, i.net_value
      i.vat = -1
      assert_equal 123.45, i.net_value
    end

    def test_vat_value
      i = Invoice.new({price: 123.45, gross_price: false, vat: 23})
      assert_equal 28.39, i.vat_value
      i.gross_price = true
      assert_equal 23.08, i.vat_value
      i.vat = 0
      assert_equal 0.00, i.vat_value
      i.vat = -1
      assert_equal 0.00, i.vat_value
    end

    def test_gross_value
      i = Invoice.new({price: 123.45, gross_price: false, vat: 23})
      assert_equal 151.84, i.gross_value
      i.gross_price = true
      assert_equal 123.45, i.gross_value
      i.vat = 0
      assert_equal 123.45, i.gross_value
      i.vat = -1
      assert_equal 123.45, i.gross_value
      i.gross_price = false
      i.vat = 0
      assert_equal 123.45, i.gross_value
      i.vat = -1
      assert_equal 123.45, i.gross_value
    end

    def test_defaults
      i = Invoice.new
      assert i.gross_price
      assert 23, i.vat
      assert 'Przelew', i.payment_type
      assert i.paid
      assert_equal false, i.proforma
    end

    def test_raise_when_save_to_pdf_and_not_valid
      i = Invoice.new
      assert_raises(RuntimeError) { i.to_pdf('/tmp/test.pdf') }
    end

    def test_to_pdf
      i = create_valid_invoice
      path = '/tmp/test.pdf'
      i.to_pdf(path)
      assert File.exists?(path)
      File.unlink(path)
    end

    def test_to_hash
      i = Invoice.new({price: 123.45})
      h = i.to_hash
      assert_equal 23, h[:vat] # default
      assert_equal 123.45, h[:price] # params
    end
  end
end
