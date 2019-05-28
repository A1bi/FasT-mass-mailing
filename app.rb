# frozen_string_literal: true

require 'optparse'
require 'byebug'
require './address_parser'
require './letters_pdf'

action = ARGV.first
options = {}

abort('Please specify one of the following actions: list, letters, sample.') unless %w[letters list sample].include? action

OptionParser.new do |opts|
  opts.banner = "Usage: app.rb #{action} [options]"

  unless action == 'list'
    opts.on('--content CONTENT', 'content file') do |value|
      options[:content_name] = value
    end
  end

  unless action == 'sample'
    opts.on('--address-file PATH', 'file containing all addresses') do |value|
      options[:addresses_path] = value
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

unless action == 'list'
  abort('Specified content file does not exist.') unless File.exist? "content/#{options[:content_name]}.txt"

  pdf = FasTMassMailing::LettersPDF.new(content_name: options[:content_name])
end

case action
when 'letters'
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

when 'sample'
  pdf.add_letter(
    name: 'Max Mustermann',
    street: 'Musterstraße 1',
    plz: '12345',
    city: 'Musterhausen'
  )

  pdf.render_file('sample.pdf')
end
