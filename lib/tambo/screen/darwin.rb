# frozen_string_literal: true

module Tambo
  module Screen
    require "io/console"
    require "termios"

    class Darwin
      def initialize
        Logger.clear_debug_log
        @terminfo = Tambo::Terminfo.new(ENV["TERM"])
        @charset = "UTF-8"
        @input = IO.console
        @output = IO.console
        set_noncanonical_mode
        @cell_buffer = Tambo::CellBuffer.new(@terminfo)
        width = @terminfo.columns
        height = @terminfo.lines
        width, height = winsize
        @cell_buffer.resize(width, height)
        resize

        @event_scanner = Tambo::Event::Scanner.new

        @event_receiver = Ractor.new name: "event_receiver" do
          loop do
            event = Ractor.receive
            Ractor.yield({ event: event })
          end
        end

        @key_receiver = Ractor.new @input, name: "key_receiver" do |input|
          loop do
            outbuf = input.readpartial(128)
            next unless outbuf.length.positive?

            Ractor.yield({ chunk: outbuf })
          end
        end

        # main loop
        shared = [@event_receiver, @key_receiver, @event_scanner]
        Ractor.new shared do |shared|
          event_receiver, key_receiver, event_scanner = shared
          loop do
            ractor, response = Ractor.select(key_receiver)
            case ractor.name.to_sym
            when :key_receiver
              key = response[:chunk]
              event = event_scanner.scan(key)
              event_receiver.send event
            end
          end
        end
      end

      def write(content)
        resize
        @cell_buffer.write(content)
      end

      def draw
        s = @cell_buffer.to_s
        @output.write(s)
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
        set_canonical_mode
        @input&.close
        @output&.close
      end

      def poll_event
        ractor, response = Ractor.select(@event_receiver)
        return response[:event] if response

        nil
      end

      def size
        winsize
      end

      def beep
        @output.write("\007")
      end

      private

      def winsize
        height, width = @output.winsize
        [width, height]
      rescue IOError, NoMethodError
        [-1, -1]
      end

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
