require 'simplecov'
SimpleCov.start do
  add_filter '/test/'
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'polish_invoicer'
require 'minitest/autorun'

def create_valid_invoice
  invoice = PolishInvoicer::Invoice.new({
    number: '1/2014', create_date: Date.today, trade_date: Date.today,
    seller: ['Seller'], buyer: ['Buyer'], item_name: 'Title',
    price: 123.45, payment_date: Date.today
  })
  assert invoice.valid?
  invoice
end
