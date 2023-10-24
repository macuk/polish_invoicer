# frozen_string_literal: true

require 'test_helper'

module PolishInvoicer
  class WriterTest < Minitest::Test
    def test_save_to_html
      invoice = create_valid_invoice
      writer = Writer.new(invoice)
      path = '/tmp/test.html'
      writer.save_to_html(path)

      assert_path_exists path
      File.unlink(path)
    end

    def test_save_to_pdf
      invoice = create_valid_invoice
      writer = Writer.new(invoice)
      path = '/tmp/test.pdf'
      writer.save_to_pdf(path)

      assert_path_exists path
      File.unlink(path)
    end

    def test_setting_additional_params
      invoice = create_valid_invoice
      invoice.template_path = 'tpl.slim'
      invoice.logger = 'FakeLogger'
      invoice.wkhtmltopdf_command = 'wkhtmltopdf_fake_command'
      writer = Writer.new(invoice)

      assert_equal 'tpl.slim', writer.template_path
      assert_equal 'FakeLogger', writer.logger
      assert_equal 'wkhtmltopdf_fake_command', writer.wkhtmltopdf_command
    end
  end
end
