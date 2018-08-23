# frozen_string_literal: true

require 'byebug'
require './address_parser'
require './letters_pdf'

action = ARGV.first

abort('Please specify one of the following actions: list, letters.') unless %w[letters list].include? action

vcf_file = ARGV.last

abort('Please specify a CSV file containing addresses.') if vcf_file.nil?
abort('Specified CSV file does not exist.') unless File.exist? vcf_file

begin
  addresses = FasTMassMailing::AddressParser.parse_vcf_file(vcf_file)
rescue RuntimeError => error
  abort(error.to_s)
end

addresses.sort_by! { |address| address[:plz] }

case action
when 'letters'
  pdf = FasTMassMailing::LettersPDF.new

  addresses.each_with_index do |address, i|
    puts "Adding letter #{i + 1} of #{addresses.count}"
    pdf.add_letter(address)
  end

  pdf.render_file('letters.pdf')

when 'list'
  open('addresses.txt', 'w') do |f|
    addresses.each do |address|
      f.puts "#{address[:name]} – #{address[:street]} – #{address[:plz]} #{address[:city]}\n"
    end
  end
end
