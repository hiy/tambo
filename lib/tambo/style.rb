# frozen_string_literal: true

module Tambo
  class Style
    attr_accessor :color, :bgcolor

    def initialize(color: Tambo::Color.new, bgcolor: Tambo::Color.new)
      @color = color
      @bgcolor = bgcolor
      yield self if block_given?
    end

    def color=(color)
      color =
        if color.is_a?(Tambo::Color)
          color
        else
          Tambo::Color.new(color)
        end

      @color = color
    end

    def bgcolor=(color)
      c =
        if color.is_a?(Tambo::Color)
          color
        else
          Tambo::Color.new(color)
        end
      @bgcolor = color
    end
  end
end
