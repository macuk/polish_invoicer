# frozen_string_literal: true

module PolishInvoicer
  class Validator
    attr_reader :errors

    def initialize(invoice)
      @invoice = invoice
      @errors = {}
    end

    def valid?
      @errors = {}
      check_presence
      check_not_nil
      check_dates
      check_arrays
      check_booleans
      check_price
      check_price_paid
      check_vat
      check_proforma
      check_create_and_payment_date
      check_currency
      check_lang
      @errors.empty?
    end

    private

    def check_presence
      check_blank(:number, 'Numer nie może być pusty')
      check_blank(:create_date, 'Data wystawienia nie może być pusta')
      check_blank(:trade_date, 'Data sprzedaży nie może być pusta')
      check_blank(:seller, 'Sprzedawca nie może być pusty')
      check_blank(:buyer, 'Nabywca nie może być pusty')
      check_blank(:item_name, 'Nazwa usługi nie może być pusta')
      check_blank(:price, 'Cena nie może być pusta')
      check_blank(:vat, 'Stawka VAT nie może być pusta')
      check_blank(:payment_type, 'Rodzaj płatności nie może być pusty')
      check_blank(:payment_date, 'Termin płatności nie może być pusty')
      check_blank(:seller_nip, 'NIP sprzedawcy nie może być pusty')
    end

    def check_not_nil
      if @invoice.gross_price.nil?
        @errors[:gross_price] =
          'Konieczne jest ustawienie znacznika rodzaju ceny (netto/brutto)'
      end
      @errors[:paid] = 'Konieczne jest ustawienie znacznika opłacenia faktury' if @invoice.paid.nil?
      @errors[:currency] = 'Konieczne jest ustawienie waluty rozliczeniowej' if @invoice.currency.nil?
      @errors[:exchange_rate] = 'Konieczne jest podanie kursu waluty rozliczeniowej' if @invoice.exchange_rate.nil?
    end

    def check_arrays
      @errors[:seller] = 'Sprzedawca musi być podany jako tablica stringów' unless @invoice.seller.is_a?(Array)
      @errors[:buyer] = 'Nabywca musi być podany jako tablica stringów' unless @invoice.buyer.is_a?(Array)
    end

    def check_booleans
      unless [true, false].include?(@invoice.gross_price)
        @errors[:gross_price] = 'Znacznik rodzaju ceny musi być podany jako boolean'
      end
      @errors[:paid] = 'Znacznik opłacenia faktury musi być podany jako boolean' unless [true,
                                                                                         false].include?(@invoice.paid)
      unless [true, false].include?(@invoice.proforma)
        @errors[:proforma] = 'Znacznik faktury pro-forma musi być podany jako boolean'
      end
      unless [true, false].include?(@invoice.foreign_buyer)
        @errors[:foreign_buyer] = 'Znacznik zagranicznego nabywcy musi być podany jako boolean'
      end
      return if [true, false].include?(@invoice.reverse_charge)

      @errors[:reverse_charge] = 'Znacznik odwrotnego obciążenia VAT musi być podany jako boolean'
    end

    def check_dates
      @errors[:create_date] = 'Data wystawienia musi być typu Date' unless @invoice.create_date.is_a?(Date)
      @errors[:trade_date] = 'Data sprzedaży musi być typu Date' unless @invoice.trade_date.is_a?(Date)
      @errors[:payment_date] = 'Termin płatności musi być typu Date' unless @invoice.payment_date.is_a?(Date)
    end

    def check_price
      if @invoice.price.is_a?(Numeric)
        @errors[:price] = 'Cena musi być liczbą dodatnią' unless @invoice.price.positive?
      else
        @errors[:price] = 'Cena musi być liczbą'
      end
    end

    def check_price_paid
      return if @invoice.price_paid.nil?
      return if @invoice.price.nil?

      if @invoice.price_paid.is_a?(Numeric)
        @errors[:price_paid] = 'Kwota zapłacona musi być liczbą dodatnią' unless @invoice.price_paid >= 0
        unless @invoice.price_paid <= @invoice.price
          @errors[:price_paid] =
            'Kwota zapłacona musi być mniejsza lub równa cenie'
        end
      else
        @errors[:price_paid] = 'Kwota zapłacona musi być liczbą'
      end
    end

    def check_vat
      if Vat.valid?(@invoice.vat)
        if Vat.zw?(@invoice.vat) && blank?(@invoice.no_vat_reason)
          @errors[:no_vat_reason] = 'Konieczne jest podanie podstawy prawnej zwolnienia z podatku VAT'
        end
      else
        @errors[:vat] = 'Stawka VAT spoza listy dopuszczalnych wartości'
      end
    end

    def check_proforma
      return unless @invoice.proforma
      return unless @invoice.paid

      @errors[:paid] = 'Proforma nie może być opłacona'
    end

    def check_create_and_payment_date
      return if @errors[:create_date]
      return if @errors[:payment_date]
      return if @invoice.create_date <= @invoice.payment_date

      @errors[:payment_date] = 'Termin płatności nie może być wcześniejszy niż data wystawienia'
    end

    def check_currency
      return if @errors[:currency]
      return if %w[PLN EUR USD GBP].include?(@invoice.currency)

      @errors[:currency] = 'Nieznana waluta'
    end

    def check_lang
      return if blank?(@invoice.lang)
      return if %w[pl pl_en en es].include?(@invoice.lang)

      @errors[:lang] = 'Nieznany język'
    end

    def blank?(value)
      value.to_s.strip == ''
    end

    def check_blank(key, msg)
      value = @invoice.send(key)
      @errors[key] = msg if blank?(value)
    end
  end
end
