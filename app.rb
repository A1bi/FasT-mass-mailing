# frozen_string_literal: true

require 'optparse'
require 'byebug'
require './address_parser'
require './letters_pdf'
require './envelopes_pdf'

action = ARGV.first
options = {}

abort('Please specify one of the following actions: list, letters, sample.') unless %w[letters envelopes list sample].include? action

OptionParser.new do |opts|
  opts.banner = "Usage: app.rb #{action} [options]"

  if %w[letters sample].include? action
    opts.on('--content CONTENT', 'content file') do |value|
      options[:content_name] = value
    end
  end

  unless action == 'sample'
    opts.on('--address-file PATH', 'file containing all addresses') do |value|
      options[:addresses_path] = value
    end
  end

  if action == 'envelopes'
    opts.on('--header-file PATH', 'header svg file') do |value|
      options[:header_filename] = value
    end
  end
end.parse!

unless action == 'sample'
  abort('Specified address file does not exist.') unless File.exist? options[:addresses_path]

  begin
    addresses = FasTMassMailing::AddressParser.parse_file(options[:addresses_path])
  rescue RuntimeError => e
    abort(e.to_s)
  end

  addresses.sort_by! { |address| address[:plz] }
end

if action == 'letters' || action == 'sample'
  abort('Specified content file does not exist.') unless File.exist? "content/#{options[:content_name]}.txt"

  pdf = FasTMassMailing::LettersPDF.new(content_name: options[:content_name])

elsif action == 'envelopes'
  abort('Specified header file does not exist.') unless File.exist? "assets/images/#{options[:header_filename]}.svg"

  pdf = FasTMassMailing::EnvelopesPDF.new(header_filename: options[:header_filename])
end

case action
when 'letters'
  addresses.each_with_index do |address, i|
    puts "Adding letter #{i + 1} of #{addresses.count}"
    pdf.add_letter(address)
  end

  pdf.render_file('letters.pdf')

when 'envelopes'
  addresses.each_with_index do |address, i|
    puts "Adding envelope #{i + 1} of #{addresses.count}"
    pdf.add_envelope(address)
  end

  pdf.render_file('envelopes.pdf')

when 'list'
  open('addresses.txt', 'w') do |f|
    addresses.each do |address|
      f.puts "#{address[:name]} – #{address[:street]} – #{address[:plz]} #{address[:city]}\n"
    end
  end

when 'sample'
  pdf.add_letter(
    name: 'Max Mustermann',
    street: 'Musterstraße 1',
    plz: '12345',
    city: 'Musterhausen'
  )

  pdf.render_file('sample.pdf')
end
