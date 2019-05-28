# frozen_string_literal: true

require 'vcardigan'
require 'csv'

module FasTMassMailing
  module AddressParser
    def self.parse_file(path)
      case File.extname(path)
      when '.csv'
        parse_csv_file(path)
      when '.vcf'
        parse_vcf_file(path)
      else
        raise 'Unknown address file format.'
      end
    end

    def self.parse_vcf_file(path)
      addresses = []

      read_cards_from_vcf_file(path) do |card, i|
        address = {
          name: card.field('x-department').first.values.first,
          street: card.adr.first.values[2],
          plz: card.adr.first.values[5],
          city: card.adr.first.values[3]
        }

        validate_address(address, i)

        addresses << address
      end

      addresses
    end

    def self.parse_csv_file(path)
      addresses = []

      i = 0
      CSV.foreach(path, col_sep: ';') do |row|
        address = {
          name: row[0],
          street: row[1],
          plz: row[2],
          city: row[3]
        }

        validate_address(address, i)

        addresses << address
        i += 1
      end

      addresses
    end

    def self.validate_address(address, row_index)
      address.each do |key, value|
        value&.strip!
        raise "Row #{row_index + 1}: Missing #{key} for: #{address}" if value.nil? || value == ''
      end
      raise "Row #{row_index + 1}: Invalid PLZ for: #{address}" if address[:plz].length != 5
    end

    def self.read_cards_from_vcf_file(path)
      card_data = ''

      File.open(path).each_with_index do |line, index|
        card_data += line
        next unless line.start_with? 'END:VCARD'

        yield VCardigan.parse(card_data), index

        card_data = ''
      end
    end
  end
end
