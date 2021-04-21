# frozen_string_literal: true

module Tambo
  class Cell
    attr_accessor :base_char,
                  :last_base_char,
                  :combining_char,
                  :last_combining_char,
                  :style,
                  :last_style,
                  :width

    def initialize
      @base_char = 0
      @combining_char = []
      @last_base_char = 0
      @last_combining_char = []
      @style = Tambo::Style.new
      @last_style = Tambo::Style.new
      @width = 0
    end
  end
end
