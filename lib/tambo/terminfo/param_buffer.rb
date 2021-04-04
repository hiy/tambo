# frozen_string_literal: true

module Tambo
  class Terminfo
    class ParamBuffer
      def initialize
        @output = StringIO.new
        @buffer = StringIO.new
      end

      def reset(str)
        @output.truncate(0)
        @output.rewind
        @buffer.truncate(0)
        @buffer.rewind

        @buffer.write(str)
        @buffer.rewind
      end

      def read
        @output.rewind
        @output.read
      end

      def write(str)
        @output.write(str)
      end

      def next_char
        byte = @buffer.readbyte
        byte.chr
      rescue EOFError
        false
      end
    end
  end
end
