# frozen_string_literal: true

module Tambo
  module Event
    class Scanner
      attr_reader :key

      def initialize; end

      def scan(key)
        Tambo::Event::Key.new(key: KEY_ESC) if key == "\x1b"
      end
    end
  end
end
