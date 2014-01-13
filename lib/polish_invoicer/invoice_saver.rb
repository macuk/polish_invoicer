module PolishInvoicer
  class InvoiceSaver
    attr_accessor :invoice, :template_path
    attr_accessor :logger, :wkhtmltopdf_path

    def initialize(invoice)
      @invoice = invoice
      @template_path = File.expand_path('../../../tpl/invoice.html.erb', __FILE__)
    end

    def to_pdf(path)
      create_dir(path)
      erb2pdf = ::Erb2pdf.new(template_path, path)
      erb2pdf.wkhtmltopdf_path = wkhtmltopdf_path if wkhtmltopdf_path
      erb2pdf.logger = logger
      data = @invoice.to_hash
      erb2pdf.footer = data[:footer]
      erb2pdf.generate(data)
    end

    protected
      def create_dir(path)
        dir = Pathname.new(path).dirname
        FileUtils.mkdir_p(dir) unless File.directory?(dir)
      end
  end
end
