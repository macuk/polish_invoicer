require 'polish_invoicer'

i = PolishInvoicer::Invoice.new(
  number: '1/2014', create_date: Date.today, trade_date: Date.today,
  seller: ['Abaka sp. z o.o.', 'ul. Jasna 10', '10-234 Kraków'],
  buyer: ['Fabryki słodyczy S.A.', 'ul. Słodka 12/34', '12-345 Warszawa'],
  item_name: 'Jakiś długi tytuł i jeszcze jakieś informacje na różne tematy oraz dodatkowy komentarz w sprawie różnej.',
  price: 123.45, payment_date: Date.today,
  comments: 'Test uwag', footer: 'Stopka faktury plus tekst promocyjny',
  seller_nip: '123-456-78-90', buyer_nip: '987-654-32-10'
)

i.save_to_pdf('/tmp/invoice-default.pdf')
i.recipient = ['Szkoła Podstawowa Nr 1', 'ul. Zielona 10', '81-222 Gdynia', 'Nr ewid: SP1/2017']
i.save_to_pdf('/tmp/invoice-with-recipient.pdf')
i.paid = false
i.save_to_pdf('/tmp/invoice-not-paid.pdf')
i.proforma = true
i.save_to_pdf('/tmp/invoice-proforma.pdf')
i.comments = ['Ala ma kota', 'Ula ma psa']
i.save_to_pdf('/tmp/invoice-array-comments.pdf')
i.pkwiu = '82.3.2'
i.save_to_pdf('/tmp/invoice-pkwiu-proforma.pdf')
i.proforma = false
i.save_to_pdf('/tmp/invoice-pkwiu-fv.pdf')
i.vat = -1
i.no_vat_reason = 'Zwolnienie przedmiotowe na podstawie art. 123 ust. 3 pkt. 10'
i.save_to_pdf('/tmp/invoice-pkwiu-fv-reason.pdf')
