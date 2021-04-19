# frozen_string_literal: true

module Tambo
  ANSI_COLORS = {
    "blue": 4,
    "white": 7
  }.freeze

  class Color
    attr_accessor :name, :number

    def initialize(name: nil, number: 0)
      @name = name
      @number = ANSI_COLORS[@name] if @name
    end

    def to_i
      number
    end
  end
end
