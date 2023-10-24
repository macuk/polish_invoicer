# frozen_string_literal: true

require 'test_helper'

module PolishInvoicer
  class PresenterTest < Minitest::Test
    require 'ostruct'

    def setup
      @invoice = OpenStruct.new
    end

    def test_format_dates
      @invoice.trade_date = Date.parse('2014-01-01')
      @invoice.create_date = Date.parse('2014-01-15')
      @invoice.payment_date = Date.parse('2014-01-30')
      data = Presenter.new(@invoice).data

      assert_equal '01.01.2014', data[:trade_date]
      assert_equal '15.01.2014', data[:create_date]
      assert_equal '30.01.2014', data[:payment_date]
    end

    def test_format_prices
      @invoice.net_value = 123.4567
      @invoice.vat_value = 23.9876
      @invoice.gross_value = 456.3378
      data = Presenter.new(@invoice).data

      assert_equal '123,46', data[:net_value]
      assert_equal '23,99', data[:vat_value]
      assert_equal '456,34', data[:gross_value]
    end

    def test_format_comments
      @invoice.comments = nil
      data = Presenter.new(@invoice).data

      assert_empty data[:comments]
      @invoice.comments = 'Test'
      data = Presenter.new(@invoice).data

      assert_equal ['Test'], data[:comments]
      @invoice.comments = %w[A B]
      data = Presenter.new(@invoice).data

      assert_equal %w[A B], data[:comments]
    end

    def test_vat
      @invoice.vat = 23
      data = Presenter.new(@invoice).data

      assert_equal '23%', data[:vat]
      @invoice.vat = 0
      data = Presenter.new(@invoice).data

      assert_equal '0%', data[:vat]
      @invoice.vat = -1
      data = Presenter.new(@invoice).data

      assert_equal 'zw.', data[:vat]
    end
  end
end
