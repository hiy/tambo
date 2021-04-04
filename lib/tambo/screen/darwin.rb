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
        @cell_buffer = Tambo::CellBuffer.new(@terminfo)
        width = @terminfo.columns
        height = @terminfo.lines
        set_noncanonical_mode
        width, height = winsize
        @cell_buffer.resize(width, height)
        resize

        @event_receiver = Ractor.new name: "event_receiver" do
          loop do
            event = Ractor.receive
            Ractor.yield({ event: event })
          end
        end

        @key_receiver = Ractor.new name: "key_receiver" do
          loop do
            chunk = Ractor.receive
            Ractor.yield({ chunk: chunk })
          end
        end

        @main_loop =
          Ractor.new [@event_receiver, @key_receiver] do |shared|
            event_receiver = shared[0]
            key_receiver = shared[1]
            loop do
              ractor, response = Ractor.select(key_receiver)

              case ractor.name.to_sym
              when :key_receiver
                key = response[:chunk]
                Logger.debug(key)
                event_receiver.send "event"
              end
            end

          end

        @input_loop =
          Ractor.new [@input, @key_receiver] do |shared|
            input_io = shared[0]
            key_receiver = shared[1]
            loop do
              input = input_io.readpartial(128)
              next unless input.length.positive?
              key_receiver.send(input)
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
        Termios.tcsetattr(@output, Termios::TCSANOW, @termios)
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
    end
  end
end
