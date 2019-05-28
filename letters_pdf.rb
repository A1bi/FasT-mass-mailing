# frozen_string_literal: true

require 'prawn'
require 'prawn/measurement_extensions'
require 'prawn-svg'

module FasTMassMailing
  class LettersPDF < Prawn::Document
    def initialize(content_name:)
      @page_margin = [0, 20.mm]
      @content_name = content_name
      @first_page_added = false

      super page_size: 'A4', page_layout: :portrait, margin: @page_margin

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
      if @first_page_added
        start_new_page
      else
        @first_page_added = true
      end

      draw_logo

      draw_address(address)

      move_down 2.cm
      draw_content

      draw_folding_marks
    end

    private

    def draw_logo
      float do
        move_down 2.cm
        svg File.read('assets/images/logo.svg'), width: 5.cm, position: :right
      end
    end

    def draw_address(address)
      move_down 45.mm

      font_size 7 do
        text 'Freilichtbühne am schiefen Turm e. V. – Mausbachstraße 11 – 56759 Kaisersesch'
      end

      move_down 5.mm

      font_size 10
      text address[:name]
      text address[:street]
      text "#{address[:plz]} #{address[:city]}"
    end

    def draw_content
      content = File.read("content/#{@content_name}.txt")
      svgs = content.scan(/###svg:(\w+):(\d\.\d)###/).to_a

      content.split(/\n*###svg:\w+:\d\.\d###\n*/).each_with_index do |part, i|
        text part, inline_format: true

        svg_file = svgs[i]
        next if svg_file.nil?

        move_down 7.mm
        svg File.read("assets/images/#{svg_file[0]}.svg"), width: bounds.width * svg_file[1].to_f, position: :center
        move_down 7.mm
      end

      move_down 5.mm
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
            horizontal_line 2.mm, 0.8.cm, at: bounds.height - 87.mm
            horizontal_line 2.mm, 0.8.cm, at: bounds.height - 192.mm
          end
        end
      end
    end
  end
end
