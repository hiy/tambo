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
        @input = IO.console
      end

      def close
        @input.close
      end

      def readpartial(s)
        @input.readpartial(s)
      end
    end

    class Output
      extend Forwardable

      def_delegators :@output

      def initialize
        @output = IO.console
        @terminfo = Tambo::Terminfo.instance
        set_noncanonical_mode
      end

      def write(str)
        @output.write(str)
      end

      def close
        @output.close
        set_canonical_mode
      end

      def clear
        tputs(@terminfo.clear_screen)
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
