# frozen_string_literal: true

require 'byebug'
require './address_parser'

vcf_file = ARGV.first

abort('Please specify a CSV file containing addresses.') if vcf_file.nil?
abort('Specified CSV file does not exist.') unless File.exist? vcf_file

begin
  addresses = FasTMassMailing::AddressParser.parse_vcf_file(vcf_file)
rescue RuntimeError => error
  abort(error)
end
