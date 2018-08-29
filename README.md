# PolishInvoicer [![Code Climate](https://codeclimate.com/github/macuk/polish_invoicer.png)](https://codeclimate.com/github/macuk/polish_invoicer) [![Build Status](https://travis-ci.org/macuk/polish_invoicer.png?branch=master)](https://travis-ci.org/macuk/polish_invoicer)

PolishInvoicer gem creates Polish invoices and proforms in HTML and PDF formats.

Description is in Polish because of a specific case of this gem.

## Installation

Add this line to your application's Gemfile:

    gem 'polish_invoicer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install polish_invoicer

## Przykład użycia

### Generowanie proformy

```ruby
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
  price: 3500,                            # cena (domyślnie brutto)
  payment_date: Date.today + 14,          # data płatności
  proforma: true,                         # znacznik proformy
  paid: false,                            # znacznik opłacenia usługi
)
if invoice.valid?
  invoice.save_to_html('/path/to/proforma.html')
  invoice.save_to_pdf('/path/to/proforma.pdf')
else
  puts invoice.errors.inspect
end
```

[Wygenerowana proforma](https://github.com/macuk/polish_invoicer/blob/master/doc/proforma.pdf?raw=true)

### Generowanie faktury

```ruby
invoice.proforma = false
invoice.paid = true
invoice.save_to_html('/path/to/invoice.html')
invoice.save_to_pdf('/path/to/invoice.pdf')
```

[Wygenerowana faktura](https://github.com/macuk/polish_invoicer/blob/master/doc/invoice.pdf?raw=true)

## Opis wszystkich dostępnych parametrów

### Parametry wymagane

    :number,              # numer faktury (string)
    :create_date,         # data wystawienia faktury (date)
    :trade_date,          # data sprzedaży (date)
    :seller,              # adres sprzedawcy (tablica stringów)
    :seller_nip,          # NIP sprzedawcy (string)
    :buyer,               # adres nabywcy (tablica stringów)
    :item_name,           # nazwa usługi (string)
    :price,               # cena w złotych (float)
    :payment_date,        # termin płatności (date)

### Parametry wymagane z ustawionymi wartościami domyślnymi

    :gross_price,         # znacznik rodzaju ceny (netto/brutto) (boolean)
                          # wartość domyślna: true, czyli brutto
    :vat,                 # stawka vat (integer ze zbioru [23, 8, 5, 0, -1]
                          # -1 oznacza zwolniony z VAT
                          # wartość domyślna: 23
    :paid,                # znacznik opłacenia usługi (boolean)
                          # wartość domyślna: true, czyli opłacona
    :proforma,            # znacznik faktury pro-forma (boolean)
                          # wartość domyślna: false
    :payment_type,        # rodzaj płatności (string)
                          # wartość domyślna: 'Przelew'
    :foreign_buyer,       # nabywcą jest firma spoza Polski (boolean)
                          # wartość domyślna: false
    :reverse_charge       # faktura z odwrotnym obciążeniem VAT (boolean)
                          # wartość domyślna: false
    :currency             # waluta rozliczeniowa (string)
                          # wartość domyślna: PLN                      
    :exchange_rate        # kurs waluty rozliczeniowej (float)
                          # wartość domyślna: 1.0000

### Parametry dodatkowe

    :buyer_nip,           # NIP nabywcy (string)
    :recipient,           # odbiorca faktury (tablica stringów)    
    :comments,            # uwagi (string lub tablica stringów)
    :pkwiu,               # numer PKWiU (string)
    :no_vat_reason,       # podstawa prawna zwolnienia z VAT (string)
    :footer,              # treść umieszczana w stopce faktury (string)

### Parametry systemowe

    :template_path,       # ścieżka do własnego szablonu faktury
    :logger,              # możliwość ustawienia loggera
                          # podczas użycia w aplikacji Rails
                          # logger ustawia się automatycznie
    :wkhtmltopdf_path     # ścieżka do polecenia wkhtmltopdf
    :wkhtmltopdf_command  # komenda wywołania polecenia wkhtmltopdf
                          # bez podawania plików html i pdf

## Walidacja parametrów i obsługa błędów

Zmienna `invoice` z poprzedniego przykładu.

```ruby
invoice.create_date = Date.today
invoice.trade_date = Date.today - 60
invoice.vat = 1
invoice.valid?
puts invoice.errors.inspect
```

    { :vat=>"Stawka VAT spoza listy dopuszczalnych wartości" }

## Dodatkowe metody

    net_value     # obliczona wartość netto
    vat_value     # obliczona kwota VAT
    gross_value   # obliczona wartość brutto
    to_hash       # hash przekazywany do szablonu faktury

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
