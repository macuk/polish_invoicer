module PolishInvoicer
  class InvoiceSaver
    attr_accessor :invoice, :template_path
    attr_accessor :logger, :wkhtmltopdf_command

    def initialize(invoice)
      @invoice = invoice
      @template_path = File.expand_path('../../../tpl/invoice.slim', __FILE__)
    end

    def save_to_html(path)
      create_writer
      @writer.save_to_html(path)
    end

    def save_to_pdf(path)
      create_writer
      @writer.save_to_pdf(path)
    end

    protected
      def create_writer
        @writer = Slim2pdf::Writer.new(template_path)
        @writer.wkhtmltopdf_command = wkhtmltopdf_command
        @writer.logger = logger
        data = @invoice.to_hash
        @writer.data = data
        @writer.footer_text = data[:footer]
      end
  end
end
