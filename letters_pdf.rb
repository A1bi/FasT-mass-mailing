# frozen_string_literal: true

require 'prawn'
require 'prawn-svg'

module FasTMassMailing
  class LettersPDF < Prawn::Document
    def initialize
      super page_size: 'A4', page_layout: :portrait, margin: [40, 65]

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

    def add_letter(address)
      draw_logo

      draw_address(address)

      move_down 60
      draw_text

      start_new_page
    end

    private

    def draw_logo
      float do
        svg File.read('assets/images/logo.svg'), width: bounds.width * 0.25, position: :right
      end
    end

    def draw_address(address)
      move_down 110

      font_size 7 do
        text 'Freilichtbühne am schiefen Turm e. V. – Mausbachstraße 11 – 56759 Kaisersesch'
      end

      move_down 10

      font_size 10
      text address[:name]
      text address[:street]
      text "#{address[:plz]} #{address[:city]}"
    end

    def draw_text
      draw_content('first')
      move_down 20

      svg File.read('assets/images/title.svg'), width: bounds.width * 0.6, position: :center

      move_down 20
      draw_content('second')

      move_down 15
      font 'Dancing Script', size: 16 do
        text 'Ihre Freilichtbühne am schiefen Turm'
      end
    end

    def draw_content(part)
      text File.read("content/#{part}.txt"), inline_format: true
    end
  end
end
