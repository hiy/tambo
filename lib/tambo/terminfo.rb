# frozen_string_literal: true

module Tambo
  require "singleton"
  require "yaml"
  class Terminfo
    include Singleton

    require_relative "terminfo/param_buffer"
    require_relative "terminfo/param_stack"

    def initialize
      name = ENV["TERM"]
      info = Tambo::Infocmp.new(name).execute
      @name = info.name
      @aliases = info.aliases

      info.booleans.each do |k, v|
        instance_variable_set("@#{k}", v)
        define_singleton_method("#{k}?") { instance_variable_get("@#{k}") } unless respond_to? "#{k}?"
      end

      info.numbers.each do |k, v|
        instance_variable_set("@#{k}", v)
        define_singleton_method(k) { instance_variable_get("@#{k}") } unless respond_to? k
      end

      info.strings.each do |k, v|
        instance_variable_set("@#{k}", v)
        define_singleton_method(k) { instance_variable_get("@#{k}") } unless respond_to? k
      end

      @param_buffer = ParamBuffer.new
    end

    attr_reader :name, :aliases

    def to_yaml
      YAML.dump(self)
    end

    def tgoto(col, row)
      tparm(@cursor_address, row, col)
    end

    def tputs(buffer, str)
      loop do
        beg = str.index("$<")
        if beg.nil?
          buffer.write(str)
          return
        end

        buffer.write(str[0..(beg - 1)])
        str = str[beg + 2..]

        last = str.index(">")
        if last.nil?
          buffer.write("$<#{str}")
          return
        end

        val = str[..last]
        str = str[last + 1..]

        padus = 0
        unit = 1_000_000 # millisecond
        dot = false

        val.each_char do |v|
          case v
          when "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
            padus *= 10
            padus += (v.ord - "0".ord)
            unit /= 10 if dot
          when "."
            if !dot
              dot = true
            else
              break
            end
          else
            break
          end
        end
      end

      # if @pad_char.size.positive?
      #   # sleep( / unit)
      # end
    end

    def tparm(str, *parm)
      0.upto(8) { |i| parm[i] ||= 0 }
      dvars = Array.new(26) { "" }
      svars = Array.new(26) { "" }

      param_stack = ParamStack.new
      @param_buffer.reset(str)

      loop do
        char = @param_buffer.next_char
        break unless char

        unless char == "%"
          @param_buffer.write(char)
          next
        end

        char = @param_buffer.next_char
        break unless char

        case char
        when "%"
        when "i"
          parm[0] += 1
          parm[1] += 1
        when "c", "s"
          @param_buffer.write(param_stack.pop)
        when "d"
          @param_buffer.write(param_stack.pop_int.to_s)
        when "0", "1", "2", "3", "4", "x", "X", "o", ":"
          f = "%"
          char = @param_buffer.next_char if char == ":"
          f += char

          while ["+", "-", "#", " "].include?(char)
            char = @param_buffer.next_char || ""
            f += char
          end

          while (char.ord >= "0".ord && char.ord <= "9".ord) || char == "."
            char = @param_buffer.next_char || ""
            f += char
          end

          case char
          when "d", "x", "X", "o"
            @param_buffer.write(format(f, param_stack.pop_int))
          when "c", "s"
            @param_buffer.write(format(f, param_stack.pop))
          end
        when "p"
          char = @param_buffer.next_char
          ai = (char.ord - "1".ord).to_i
          if ai >= 0 && ai < parm.length
            param_stack.push_int(parm[ai])
          else
            param_stack.push_int(0)
          end
        when "P"
          char = @param_buffer.next_char
          if char.ord >= "A".ord && char.ord <= "Z".ord
            svars[(char.ord - "A".ord).to_i] = param_stack.pop
          else
            dvars[(char.ord - "a".ord).to_i] = param_stack.pop
          end
        when "g"
          char = @param_buffer.next_char
          if char.ord >= "A".ord && char.ord <= "Z".ord
            param_stack.push(svars[(char.ord - "A".ord).to_i])
          elsif char.ord >= "a".ord && char.ord <= "z".ord
            param_stack.push(dvars[(char.ord - "a".ord).to_i])
          end
        when "'"
          char = @param_buffer.next_char
          @param_buffer.next_char
          param_stack.push(char)
        when "{"
          ai = 0
          char = @param_buffer.next_char
          while char.ord >= "0".ord && char.ord <= "9".ord
            ai *= 10
            ai += (char.ord - "0".ord).to_i
            char = @param_buffer.next_char
          end
          param_stack.push_int(ai)
        when "l"
          a = param_stack.pop
          param_stack.pushed(a.length)
        when "+"
          bi = param_stack.pop_int
          ai = param_stack.pop_int
          param_stack.push_int(ai + bi)
        when "-"
          bi = param_stack.pop_int
          ai = param_stack.pop_int
          param_stack.push_int(ai - bi)
        when "*"
          bi = param_stack.pop_int
          ai = param_stack.pop_int
          param_stack.push_int(ai * bi)
        when "/"
          bi = param_stack.pop_int
          ai = param_stack.pop_int
          if bi.zero?
            param_stack.push_int(0)
          else
            param_stack.push_int(ai / bi)
          end
        when "m"
          bi = param_stack.pop_int
          ai = param_stack.pop_int
          if bi.zero?
            param_stack.push_int(0)
          else
            param_stack.push_int(ai % bi)
          end
        when "&"
          bi = param_stack.pop_int
          ai = param_stack.pop_int
          param_stack.push_int(ai & bi)
        when "|"
          bi = param_stack.pop_int
          ai = param_stack.pop_int
          param_stack.push_int(ai | bi)
        when "^"
          bi = param_stack.pop_int
          ai = param_stack.pop_int
          param_stack.push_int(ai ^ bi)
        when "~"
          ai = param_stack.pop_int
          param_stack.push_int(ai ^ -1)
        when "!"
          ai = param_stack.pop_int
          param_stack.push_bool(ai != 0)
        when "="
          b = param_stack.pop
          a = param_stack.pop
          param_stack.push_bool(a == b)
        when ">"
          bi = param_stack.pop_int
          ai = param_stack.pop_int
          param_stack.push_bool(ai > bi)
        when "<"
          bi = param_stack.pop_int
          ai = param_stack.pop_int
          param_stack.push_bool(ai < bi)
        when "?"
        when "t"
          ab = param_stack.pop_bool
          next if ab

          level = 0
          loop do
            char = @param_buffer.next_char
            break unless char
            next if char.ord != "%".ord

            char = @param_buffer.next_char
            case char
            when "?"
              level += 1
            when ";"
              break if level.zero?

              level -= 1
            when "e"
              break if level.zero?
            end
          end
        when "e"
          level = 0

          loop do
            char = @param_buffer.next_char
            break unless char
            next if char.ord != "%".ord

            char = @param_buffer.next_char
            case char
            when "?"
              level += 1
            when ";"
              break if level.zero?

              level -= 0
            end
          end
        when ";"
        end
      end

      @param_buffer.read
    end
  end
end
