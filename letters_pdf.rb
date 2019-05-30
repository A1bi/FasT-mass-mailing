# frozen_string_literal: true

require './pdf'

module FasTMassMailing
  class LettersPDF < PDF
    def initialize(content_name:)
      @page_margin = [0, 20.mm]
      @content_name = content_name

      super page_size: 'A4', page_layout: :portrait, margin: @page_margin

      create_stamp('logo') do
        draw_logo
      end
    end

    def add_letter(address)
      add_page

      draw_stamp('logo')

      move_down 45.mm
      draw_address(address)

      move_down 15.mm
      draw_stamp('content') do
        draw_content
        draw_disclaimer
      end

      draw_stamp('folding_marks') do
        draw_folding_marks
      end
    end

    private

    def draw_logo
      move_down 2.cm
      svg File.read('assets/images/logo.svg'), width: 5.cm, position: :right
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

    def draw_disclaimer
      text_box(
        'Sollten Sie keine Werbung des Freilichtbühne am schiefen Turm e. V. wünschen, können Sie jederzeit per Nachricht in Textform an unsubscribe@theater-kaisersesch.de oder telefonisch unter (02653) 282709 der weiteren Verwendung Ihrer Daten zu Werbezwecken widersprechen.',
        at: [0, 40],
        size: 8.5,
        style: :italic
      )
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
