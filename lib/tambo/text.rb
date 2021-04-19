# frozen_string_literal: true

module Tambo
  require "forwardable"
  class Text
    extend Forwardable
    attr_accessor :content

    def_delegators :each_char, *Enumerable.instance_methods(false)

    class Char
      attr_reader :base_char,
                  :combining_char,
                  :style,
                  :x, :y,
                  :width

      def initialize(base_char, combining_char, x, y, style, width)
        @base_char = base_char
        @combining_char = combining_char
        @x = x
        @y = y
        @style = style
        @width = width
      end
    end

    def initialize(text, x = 0, y = 0, style = Tambo::Style.new)
      @text = text
      @x = x
      @y = y
      @style = style
    end

    def each_char
      return enum_for(:each_char) unless block_given?

      @text.each_char do |base_char|
        combining_char = []

        width = Unicode::DisplayWidth.of(base_char, 2)
        if width.zero?
          combining_char = base_char.codepoints
          base_char = " "
          width = 1
        end

        content = Char.new(base_char, combining_char, @x, @y, @style, width)

        yield(content)
        @x += width
      end
    end
  end
end
