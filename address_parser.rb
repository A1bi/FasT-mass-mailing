# frozen_string_literal: true

require 'vcardigan'

module FasTMassMailing
  module AddressParser
    def self.parse_vcf_file(file)
      addresses = []

      read_cards_from_vcf_file(file) do |card|
        address = {
          name: card.field('x-department').first.values.first,
          street: card.adr.first.values[2],
          plz: card.adr.first.values[5],
          city: card.adr.first.values[3]
        }

        validate_address(address)

        addresses << address
      end

      addresses
    end

    def self.validate_address(address)
      address.each do |key, value|
        raise "Missing #{key} for: #{address}" if value.nil? || value == ''
      end
      raise "Wrong PLZ for: #{address}" if address[:plz].length != 5
    end

    def self.read_cards_from_vcf_file(file)
      card_data = ''

      File.open(file).each do |line|
        card_data += line
        next unless line.start_with? 'END:VCARD'

        yield VCardigan.parse(card_data)

        card_data = ''
      end
    end
  end
end
