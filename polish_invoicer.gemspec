# frozen_string_literal: true

require 'English'
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'polish_invoicer/version'

Gem::Specification.new do |spec|
  spec.name          = 'polish_invoicer'
  spec.version       = PolishInvoicer::VERSION
  spec.authors       = ['Piotr Macuk']
  spec.email         = ['piotr@macuk.pl']
  spec.description   = 'Creates polish invoices and proforms as HTML or PDF files'
  spec.summary       = 'Creates polish invoices and proforms as HTML or PDF files'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-minitest'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'simplecov'

  spec.add_dependency 'rqrcode'
  spec.add_dependency 'slim2pdf'
end
