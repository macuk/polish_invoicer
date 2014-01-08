require 'test_helper'

module PolishInvoicer
  class InvoiceTest < MiniTest::Unit::TestCase
    def test_init
      i = Invoice.new
      assert i.is_a?(Invoice)
    end
  end
end
