# frozen_string_literal: true

require 'prawn'
require 'prawn/measurement_extensions'
require 'prawn-svg'

module FasTMassMailing
  class PDF < Prawn::Document
    def initialize(options = {})
      super

      @first_page_added = false
      @stamps = []

      fill_color '000000'
      stroke_color '000000'

      font_name = 'OpenSans'
      fonts = {}
      %i[normal bold italic].each do |style|
        (fonts[font_name] ||= {})[style] = "assets/fonts/#{font_name}-#{style}.ttf"
      end
      fonts['Dancing Script'] = { normal: 'assets/fonts/DancingScript-Regular.ttf' }
      font_families.update(fonts)

      font font_name
      font_size 11
      default_leading 3
    end

    protected

    def add_page
      if @first_page_added
        start_new_page
      else
        @first_page_added = true
      end
    end

    def draw_address(address)
      font_size 7 do
        text 'Freilichtbühne am schiefen Turm e. V. – Mausbachstraße 11 – 56759 Kaisersesch'
      end

      move_down 5.mm

      font_size 10
      text address[:name]
      text address[:street]
      text "#{address[:plz]} #{address[:city]}"
    end

    def create_stamp(name, &block)
      return if @stamps.include? name

      float do
        super(name, &block)
      end
      @stamps << name
    end

    def draw_stamp(name, &block)
      create_stamp(name, &block)
      stamp name
    end
  end
end
