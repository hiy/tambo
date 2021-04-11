# frozen_string_literal: true

module Tambo
  class Cell
    attr_accessor :base_char,
                  :combining_char,
                  :last_base_char,
                  :last_combining_char,
                  :style,
                  :width

    def initialize
      @base_char = 0
      @combining_char = []
      @last_base_char = 0
      @last_combining_char = []
      @width = 0
    end
  end

  class CellBuffer
    require "unicode/display_width"
    attr_reader :width, :height

    def initialize
      @terminfo = Tambo::Terminfo.instance
      @buffer = StringIO.new
      @width = 0
      @height = 0
      @cells = []

      @display_width = Unicode::DisplayWidth.new
    end

    def read(x, y)
      base_char = 0
      combining_char = []
      width = 0
      # style = Style.new

      if within_screen?(x, y)
        cell = @cells[(y * @width) + x]

        base_char = cell.base_char
        combining_char = cell.combining_char || []
        style = nil
        width = cell.width
        if width.zero? || base_char.ord < " ".ord
          width = 1
          base_char = " ".ord
        end
      end
      [base_char, combining_char, style, width]
    end

    def write(content)
      text = content
      text.each_char do |char|
        next unless within_screen?(char.x, char.y)

        cell = @cells[(char.y * @width) + char.x]
        cell.base_char = char.base_char.ord
        cell.combining_char = char.combining_char
        cell.width = @display_width.of(char.base_char) if cell.base_char != char.base_char
        # cell.style
      end
    end

    def dirty?(x, y)
      if within_screen?(x, y)
        cell = @cells[(y * @width) + x]
        return true if cell.last_base_char.ord.zero?
        return true if cell.last_base_char != cell.base_char
        # return true if cell.last_style != cell.style
        return true if cell.last_combining_char.size != cell.combining_char.size

        cell.last_combining_char.each.with_index do |_c, i|
          return true if cell.last_combining_char[i] != cell.combining_char[i]
        end
      end
      false
    end

    def set_dirty(x, y, dirty)
      if within_screen?(x, y)
        cell = @cells[(y * @width) + x]
        if dirty
          cell.last_base_char = 0
        else
          cell.base_char = " ".ord if cell.base_char.ord.zero?
          cell.last_base_char = cell.base_char
          cell.last_combining_char = cell.combining_char
          # cell.last_style = cell.style
        end
      end
    end

    def to_s
      @cx = -1
      @cy = -1
      @buffer.truncate(0)
      @buffer.rewind

      0.upto(@height - 1) do |y|
        current_x = 0
        0.upto(@width - 1) do |x|
          next if current_x >= x && !x.zero?

          base_char, combining_char, style, width = read(x, y)

          # Logger.debug("@width: #{@width}  @height: #{@height}")
          # Logger.debug("@current_x: #{@current_x}  @current_y: #{@current_y}")
          # Logger.debug("x: #{x}  y: #{y}")

          if dirty?(x, y)
            if @cx != x || @cy != y
              @terminfo.tputs(@buffer, @terminfo.tgoto(x, y))
              @cx = x
              @cy = y
            end

            width = 1 if width < 1

            str = base_char.chr("UTF-8")
            @buffer.write(str)
            @cx += width
            set_dirty(x, y, false)
            @cx = -1 if width > 1
          end

          set_dirty(x + 1, y, true) if width > (1) && (x + 1 < @width)
          current_x = x + (width - 1)
        end
      end
      @buffer.rewind
      @buffer.read
    end

    def resize(width, height)
      return [width, height] if @width == width && @height == height

      new_cells = Array.new(width * height) { Cell.new }
      min_height = [height, @height].min
      min_width = [width, @width].min
      min_height.times do |y|
        min_width.times do |x|
          cell = @cells[(y * @width) + x]
          new_cell = new_cells[(y * width) + x]
          new_cell.base_char = cell.base_char
          new_cell.combining_char = cell.combining_char
          # new_cell.curr_style = cell.curr_style
          new_cell.width = cell.width
          new_cell.last_base_char = 0
        end
      end
      @cells = new_cells

      @width = width
      @height = height
      [@width, @height]
    end

    def fill(char, _style)
      @cells.each do |cell|
        cell.base_char = char.ord
        cell.combining_char = []
        # cell.style = style
        cell.width = 1
      end
    end

    def clear
      fill(" ", nil)
    end

    def invalidate
      @cells.each do |cell|
        cell.last_base_char = 0
      end
    end

    private

    def within_screen?(x, y)
      x >= 0 && y >= 0 && x < @width && y < @height
    end
  end
end
