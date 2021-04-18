# frozen_string_literal: true

module Tambo
  module Event
    class Scanner
      attr_reader :key

      def initialize
        @terminfo = Tambo::Terminfo.instance
        @escaped = false
      end

      def scan(buffer)
        events = []
        loop do
          pos = buffer.pos
          bytes = buffer.each_byte.to_a
          buffer.pos = pos

          if bytes.empty?
            buffer.truncate(0)
            buffer.rewind
            return events
          end

          if bytes.first == Tambo::KeyEscape
            if bytes.length == 1
              events << Tambo::Event::Key.new(key: Tambo::KeyESC)
              @escaped = false
            else
              @escaped = true
            end
            buffer.readbyte
            next
          end
          break
        end
        events
      end
    end
  end
end
