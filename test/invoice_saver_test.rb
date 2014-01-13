# encoding: utf-8
require 'test_helper'

module PolishInvoicer
  class InvoiceSaverTest < MiniTest::Unit::TestCase
    def test_to_pdf
      invoice = create_valid_invoice
      saver = InvoiceSaver.new(invoice)
      path = '/tmp/test.pdf'
      saver.to_pdf(path)
      assert File.exists?(path)
      File.unlink(path)
    end

    def test_to_pdf_with_subdir_creation
      invoice = create_valid_invoice
      saver = InvoiceSaver.new(invoice)
      path = '/tmp/a/b/c/d/test.pdf'
      saver.to_pdf(path)
      assert File.exists?(path)
      File.unlink(path)
    end
  end
end
