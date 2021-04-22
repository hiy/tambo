# frozen_string_literal: true

module Tambo
  class Style
    attr_reader :color, :bgcolor, :attributes

    def initialize(color: Tambo::Color.new, bgcolor: Tambo::Color.new, attributes: 0)
      @color = Color.parse color
      @bgcolor = Color.parse bgcolor
      @attributes = attributes
      yield self if block_given?
    end

    def color=(new_color)
      @color = Color.parse(new_color)
    end

    def bgcolor=(new_bgcolor)
      @bgcolor = Color.parse(new_bgcolor)
    end
  end
end
