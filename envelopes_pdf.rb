# frozen_string_literal: true

require './pdf'

module FasTMassMailing
  class EnvelopesPDF < PDF
    WAVE_WIDTH = 44.mm

    def initialize(header_filename:)
      super page_size: [110.mm, 220.mm], page_layout: :landscape, margin: 15.mm

      @header_filename = header_filename
    end

    def add_envelope(address)
      add_page

      draw_stamp('header') do
        draw_wave
        draw_header
      end

      move_down 45.mm
      draw_address(address)
    end

    private

    def draw_wave
      float do
        svg File.read('assets/images/wave.svg'), width: WAVE_WIDTH, position: :right
      end
    end

    def draw_header
      return unless @header_filename

      svg File.read("assets/images/#{@header_filename}.svg"), height: 2.cm
    end
  end
end
