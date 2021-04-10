# frozen_string_literal: true

module Tambo
  module Screen
    class Darwin
      def initialize
        Logger.clear_debug_log
        @terminfo = Tambo::Terminfo.instance
        @charset = "UTF-8"
        @input = Tambo::Screen::Input.new
        @output = Tambo::Screen::Output.new
        @cell_buffer = Tambo::CellBuffer.new
        width = @terminfo.columns
        height = @terminfo.lines
        width, height = size
        @cell_buffer.resize(width, height)
        resize

        @event_scanner = Tambo::Event::Scanner.new

        @event_receiver = Ractor.new name: "event_receiver" do
          loop do
            event = Ractor.receive
            Ractor.yield({ event: event })
          end
        end

        # key input loop
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
        @output.write(@cell_buffer.to_s)
      end

      def show
        resize
        draw
      end

      def resize
        @width, @height = size
        @cell_buffer.resize(@width, @height)
      end

      def clear
        @cell_buffer.clear
        @output.clear
      end

      def close
        @input&.close
        @output&.close
      end

      def poll_event
        ractor, response = Ractor.select(@event_receiver)
        return response[:event] if response

        nil
      end

      def size
        @output.winsize
      end

      def beep
        @output.write("\007")
      end

      private
    end
  end
end
