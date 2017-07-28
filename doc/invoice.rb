require 'polish_invoicer'

invoice = PolishInvoicer::Invoice.new(
  number: '1/2014',                       # numer faktury
  create_date: Date.today,                # data wystawienia
  trade_date: Date.today,                 # data wykonania usługi
  seller: ['Systemy Internetowe S.A.',    # dane sprzedawcy
           'ul. Jasna 10',
           '12-345 Kraków'],
  seller_nip: '123-456-78-90',            # NIP sprzedawcy
  buyer: ['Mała Firma sp. z o.o.',        # dane nabywcy
          'ul. Czerwona 20/4',
          '10-043 Olsztyn'],
  buyer_nip: '987-654-32-10',             # NIP nabywcy
  item_name: 'Usługi programistyczne',    # nazwa usługi
  price: 100,                             # cena (domyślnie brutto)
  payment_date: Date.today + 14,          # data płatności
  gross_price: false,
  # proforma: true,
  # paid: false,
  foreign_buyer: true,
  reverse_charge: true
)
invoice.save_to_html('/tmp/invoice.html')
invoice.save_to_pdf('/tmp/invoice.pdf')
