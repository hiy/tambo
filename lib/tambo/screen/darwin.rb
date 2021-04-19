# frozen_string_literal: true

module Tambo
  module Screen
    class Darwin
      attr_accessor :style

      def initialize
        Logger.clear_debug_log
        @terminfo = Tambo::Terminfo.instance
        Logger.dump_to_yaml(@terminfo)
        @charset = "UTF-8"
        @input = Tambo::Screen::Input.new
        @output = Tambo::Screen::Output.new
        @cell_buffer = Tambo::CellBuffer.new

        @event_receiver = Ractor.new name: "event_receiver" do
          loop do
            event = Ractor.receive
            Ractor.yield({ event: event })
          end
        end

        # key input loop
        @key_receiver = Ractor.new @input, name: "key_receiver" do |input|
          loop do
            outbuf = input.read
            next unless outbuf.length.positive?

            Ractor.yield({ chunk: outbuf })
          end
        end

        width, height = size
        @cell_buffer.resize(width, height)
        @width = width
        @height = height
        resize

        @output.enter_ca_mode
        @output.hide_cursor
        @output.clear

        # window resize signal
        Signal.trap("SIGWINCH") do |_signo|
          Logger.debug("SIGWINCH")
          resize
          @cell_buffer.invalidate
          draw
        end

        # main loop
        shared = [
          @event_receiver,
          @key_receiver,
          Tambo::Event::Scanner.new
        ]
        Ractor.new shared do |shared|
          event_receiver, key_receiver, event_scanner = shared
          key_buffer = StringIO.new

          loop do
            ractor, response = Ractor.select(key_receiver)
            case ractor.name.to_sym
            when :key_receiver
              pos = key_buffer.pos
              key_buffer.write(response[:chunk])
              key_buffer.pos = pos
              events = event_scanner.scan(key_buffer)
              events.each { |event| event_receiver.send event }
            end
          end
        end
      end

      def write(content)
        resize
        @cell_buffer.write(content)
      end

      def show
        resize
        draw
      end

      def clear
        # Logger.debug("darwin#clear")
        @cell_buffer.clear
      end

      def close
        @cell_buffer.resize(0, 0)

        @output.buffering do |buffer|
          @terminfo.tputs(buffer, @terminfo.cursor_visible)
          @terminfo.tputs(buffer, @terminfo.clear_screen)
        end

        @output.write

        @input&.close
        @output&.close
      end

      def sync
        resize
        draw
      end

      def poll_event
        ractor, response = Ractor.select(@event_receiver)
        return response[:event] if response

        nil
      end

      def size
        @output.winsize
      end

      def colors; end

      def beep
        @output.write("\007")
      end

      private

      def draw
        @output.buffering do |buffer|
          @terminfo.tputs(buffer, @terminfo.cursor_invisible)
          @terminfo.tputs(buffer, @terminfo.clear_screen)
          s = @cell_buffer.to_s
          Logger.debug("#{self.class}##{__method__}: #{s}")
          buffer.write(s)
          @terminfo.tputs(buffer, @terminfo.cursor_visible)
        end

        @output.write
      end

      def resize
        if resized?
          width, height = size
          @cell_buffer.resize(width, height)
          @cell_buffer.invalidate
          @width = width
          @height = height
          resize_event = Event::Resize.new(width: width, height: height)
          @event_receiver.send resize_event
        end
      end

      def resized?
        width, height = size
        width != @width || height != @height
      end
    end
  end
end
