# frozen_string_literal: true

module Tambo
  module Screen
    class Darwin
      require "io/console"
      require "termios"
      def initialize
        Logger.clear_debug_log
        @terminfo = Tambo::Terminfo.new(ENV["TERM"])
        @buffer = StringIO.new
        @charset = "UTF-8"
        @input = File.open("/dev/tty", "r") # read only
        @output = File.open("/dev/tty", "w") # write only
        # @output = IO.console
        @cell_buffer = Tambo::CellBuffer.new(@terminfo)
        width = @terminfo.columns
        height = @terminfo.lines
        set_noncanonical_mode

        width, height = winsize
        @cell_buffer.resize(width, height)
        resize
      end

      def write(content)
        resize
        @cell_buffer.write(content)
      end

      def draw
        @buffer.truncate(0)
        @buffer.rewind
        str = @cell_buffer.to_s
        Logger.debug(str)
        @output.write(str)
      end

      def show
        resize
        draw
      end

      def resize
        @width, @height = winsize
        @cell_buffer.resize(@width, @height)
      end

      def clear; end

      def close
        Termios.tcsetattr(@output, Termios::TCSANOW, @termios)
        @input&.close
        @output&.close
      end

      def winsize
        height, width = @output.winsize
        [width, height]
      rescue IOError, NoMethodError
        [-1, -1]
      end

      def size
        winsize
      end

      def beep; end

      private

      def set_noncanonical_mode
        @termios = Termios.tcgetattr(@output)
        # It is possible to put the terminal in noncanonical mode
        # and get input immediately.
        new_termios = @termios.dup
        new_termios.iflag &= ~(Termios::IGNBRK | Termios::BRKINT | Termios::PARMRK |
          Termios::ISTRIP | Termios::INLCR | Termios::IGNCR |
          Termios::ICRNL | Termios::IXON)
        new_termios.oflag &= ~Termios::OPOST
        new_termios.lflag &= ~(Termios::ECHO | Termios::ECHONL | Termios::ICANON | Termios::ISIG | Termios::IEXTEN)
        new_termios.cflag &= ~(Termios::CSIZE | Termios::PARENB)
        new_termios.cflag |= Termios::CS8
        Termios.tcsetattr(@output, Termios::TCSANOW, new_termios)
      end
    end
  end
end
