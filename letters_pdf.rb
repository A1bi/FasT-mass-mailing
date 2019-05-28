# frozen_string_literal: true

require 'prawn'
require 'prawn/measurement_extensions'
require 'prawn-svg'

module FasTMassMailing
  class LettersPDF < Prawn::Document
    def initialize(content_name:)
      @page_margin = [40, 65]

      super page_size: 'A4', page_layout: :portrait, margin: @page_margin

      @content_name = content_name

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
      draw_content

      draw_folding_marks

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

    def draw_content
      text File.read("content/#{@content_name}.txt"), inline_format: true

      # move_down 20
      # svg File.read('assets/images/title.svg'), width: bounds.width * 0.6, position: :center

      move_down 15
      font 'Dancing Script', size: 16 do
        text 'Ihre Freilichtbühne am schiefen Turm'
      end
    end

    def draw_folding_marks
      float do
        bounding_box(
          [-@page_margin[1], bounds.height + @page_margin[0]],
          width: bounds.width + @page_margin[1] * 2,
          height: bounds.height + @page_margin[0] * 2
        ) do
          stroke do
            line_width 0.1.mm
            horizontal_line 5.mm, 1.cm, at: 87.mm
            horizontal_line 5.mm, 1.cm, at: 192.mm
          end
        end
      end
    end
  end
end
