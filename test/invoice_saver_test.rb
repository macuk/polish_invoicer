# encoding: utf-8
require 'test_helper'

module PolishInvoicer
  class InvoiceSaverTest < MiniTest::Unit::TestCase
    def test_save_to_html
      invoice = create_valid_invoice
      saver = InvoiceSaver.new(invoice)
      path = '/tmp/test.html'
      saver.save_to_html(path)
      assert File.exists?(path)
      File.unlink(path)
    end

    def test_save_to_pdf
      invoice = create_valid_invoice
      saver = InvoiceSaver.new(invoice)
      path = '/tmp/test.pdf'
      saver.save_to_pdf(path)
      assert File.exists?(path)
      File.unlink(path)
    end
  end
end
