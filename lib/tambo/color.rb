# frozen_string_literal: true

module Tambo
  class Color
    attr_accessor :name, :number

    class << self
      def parse(color)
        case color
        when String
          new(name: color)
        when Integer
          new(number: color)
        when Tambo::Color
          color
        end
      end
    end

    def initialize(name: nil, number: 0)
      @name = name
      @number = ANSI_COLORS[@name] if @name
    end

    def to_i
      number
    end
  end
end
