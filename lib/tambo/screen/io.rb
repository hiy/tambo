# frozen_string_literal: true

module Tambo
  module Screen
    require "forwardable"
    require "io/console"
    require "termios"

    class Input
      extend Forwardable
      def_delegators :@input,
                     :readpartial

      def initialize
        @input = File.open("/dev/tty", "r") # IO.console
      end

      def close
        @input.close
      end

      def read
        @input.readpartial(128)
      end
    end

    class Output
      extend Forwardable

      attr_reader :buffer
      def_delegators :@output

      class Buffer
      end

      def initialize
        @output = File.open("/dev/tty", "w") #IO.console
        @terminfo = Tambo::Terminfo.instance
        @buffer = StringIO.new
        set_noncanonical_mode
      end

      def buffering
        @buffer.truncate(0)
        @buffer.rewind
        yield @buffer
      end

      def read_buffer
        @buffer.rewind
        @buffer.read
      end

      def write_buffer
        @buffer.rewind
        s = @buffer.read
        # Logger.debug(s)
        @output.write(s)
        @buffer.truncate(0)
        @buffer.rewind
      end

      def write(str)
        @output.write(str)
      end

      def close
        set_canonical_mode
        @output.close
      end

      def clear
        tputs(@terminfo.clear_screen)
      end

      def enter_ca_mode
        tputs(@terminfo.enter_ca_mode)
      end

      def show_cursor
        tputs(@terminfo.cursor_visible)
      end

      def hide_cursor
        tputs(@terminfo.cursor_invisible)
      end

      def tputs(str)
        @terminfo.tputs(@output, str)
      end

      def winsize
        height, width = @output.winsize
        [width, height]
      rescue IOError, NoMethodError
        [-1, -1]
      end

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

      def set_canonical_mode
        Termios.tcsetattr(@output, Termios::TCSANOW, @termios)
      end
    end
  end
end
