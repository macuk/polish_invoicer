# frozen_string_literal: true

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

      refute_predicate i, :valid?
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

      assert_in_delta(0.00, i.vat_value)
      i.vat = -1

      assert_in_delta(0.00, i.vat_value)
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
      assert_equal 23, i.vat
      assert_equal 'Przelew', i.payment_type
      assert i.paid
      refute i.proforma
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

      assert_path_exists path
      File.unlink(path)
    end

    def test_save_to_pdf
      i = create_valid_invoice
      path = '/tmp/test.pdf'
      i.save_to_pdf(path)

      assert_path_exists path
      File.unlink(path)
    end

    def test_to_hash
      i = Invoice.new(price: 123.45, gross_price: false)
      h = i.to_hash

      assert h[:paid] # default
      refute h[:gross_price] # params
      assert_equal '123,45', h[:net_value] # presenter
    end

    def test_total_to_pay_value
      assert_equal 123, Invoice.new(price: 123).paid_value
      assert_equal 100, Invoice.new(price: 123, reverse_charge: true).paid_value
    end

    def test_paid_value
      assert_equal 123, Invoice.new(price: 123).paid_value
      assert_equal 123, Invoice.new(price: 123, price_paid: 100).paid_value
      assert_equal 0, Invoice.new(price: 123, paid: false).paid_value
      assert_equal 100, Invoice.new(price: 123, paid: false, price_paid: 100).paid_value
      assert_equal 100, Invoice.new(price: 123, gross_price: false, paid: false, price_paid: 100).paid_value
      assert_equal 100, Invoice.new(price: 123, reverse_charge: true, paid: false, price_paid: 100).paid_value
    end

    def test_to_pay_value
      assert_equal 0, Invoice.new(price: 123).to_pay_value
      assert_equal 0, Invoice.new(price: 123, price_paid: 100).to_pay_value
      assert_equal 123, Invoice.new(price: 123, paid: false).to_pay_value
      assert_equal 23, Invoice.new(price: 123, paid: false, price_paid: 100).to_pay_value
      assert_equal 23, Invoice.new(price: 100, gross_price: false, paid: false, price_paid: 100).to_pay_value
      assert_equal 50, Invoice.new(price: 123, reverse_charge: true, paid: false, price_paid: 50).to_pay_value
    end

    def test_gross_and_net_price
      gross_invoice = Invoice.new(price: 123, price_paid: 60, paid: false)

      assert_equal 100, gross_invoice.net_value
      assert_equal 23, gross_invoice.vat_value
      assert_equal 123, gross_invoice.gross_value
      assert_equal 123, gross_invoice.total_to_pay_value
      assert_equal 60, gross_invoice.paid_value
      assert_equal 63, gross_invoice.to_pay_value

      net_invoice = Invoice.new(price: 100, price_paid: 60, paid: false, gross_price: false)

      assert_equal 100, net_invoice.net_value
      assert_equal 23, net_invoice.vat_value
      assert_equal 123, net_invoice.gross_value
      assert_equal 123, net_invoice.total_to_pay_value
      assert_equal 60, net_invoice.paid_value
      assert_equal 63, net_invoice.to_pay_value
    end

    def test_reverse_charge
      gross_invoice = Invoice.new(price: 123, price_paid: 60, paid: false, reverse_charge: true)

      assert_equal 100, gross_invoice.net_value
      assert_equal 23, gross_invoice.vat_value
      assert_equal 123, gross_invoice.gross_value
      assert_equal 100, gross_invoice.total_to_pay_value
      assert_equal 60, gross_invoice.paid_value
      assert_equal 40, gross_invoice.to_pay_value

      net_invoice = Invoice.new(price: 100, price_paid: 60, paid: false, gross_price: false, reverse_charge: true)

      assert_equal 100, net_invoice.net_value
      assert_equal 23, net_invoice.vat_value
      assert_equal 123, net_invoice.gross_value
      assert_equal 100, net_invoice.total_to_pay_value
      assert_equal 60, net_invoice.paid_value
      assert_equal 40, net_invoice.to_pay_value
    end

    def test_template_lang
      i = Invoice.new

      assert_equal 'pl', i.template_lang
      i.foreign_buyer = true

      assert_equal 'pl_en', i.template_lang
      i.lang = 'en'

      assert_equal 'en', i.template_lang
    end

    def test_template_file
      i = Invoice.new(proforma: true)

      assert_equal 'proforma-pl.slim', i.template_file
      i.foreign_buyer = true

      assert_equal 'proforma-pl_en.slim', i.template_file
      i.lang = 'en'

      assert_equal 'proforma-en.slim', i.template_file
      i.lang = 'pl'

      assert_equal 'proforma-pl.slim', i.template_file
      i.lang = 'pl_en'

      assert_equal 'proforma-pl_en.slim', i.template_file

      i = Invoice.new

      assert_equal 'invoice-pl.slim', i.template_file
      i.foreign_buyer = true

      assert_equal 'invoice-pl_en.slim', i.template_file
      i.lang = 'en'

      assert_equal 'invoice-en.slim', i.template_file
      i.lang = 'pl'

      assert_equal 'invoice-pl.slim', i.template_file
      i.lang = 'pl_en'

      assert_equal 'invoice-pl_en.slim', i.template_file
    end
  end
end
