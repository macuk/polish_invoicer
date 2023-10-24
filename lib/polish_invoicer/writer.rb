# frozen_string_literal: true

module PolishInvoicer
  class Writer
    attr_accessor :invoice, :logger, :wkhtmltopdf_path, :wkhtmltopdf_command

    def initialize(invoice)
      @invoice = invoice
      @logger = @invoice.logger
      @wkhtmltopdf_path = @invoice.wkhtmltopdf_path
      @wkhtmltopdf_command = @invoice.wkhtmltopdf_command
    end

    def save_to_html(path)
      create_writer
      @writer.save_to_html(path)
    end

    def save_to_pdf(path)
      create_writer
      @writer.save_to_pdf(path)
    end

    def template_path
      tpl = invoice.template_file
      invoice.template_path || File.expand_path("../../../tpl/#{tpl}", __FILE__)
    end

    private

    def create_writer
      @writer = Slim2pdf::Writer.new(template_path)
      @writer.wkhtmltopdf_path = wkhtmltopdf_path
      @writer.wkhtmltopdf_command = wkhtmltopdf_command
      @writer.logger = logger
      data = @invoice.to_hash
      @writer.data = data
      @writer.footer_text = data[:footer]
    end
  end
end
