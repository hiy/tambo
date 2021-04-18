# frozen_string_literal: true

module Tambo
  module Event
    class Resize
      attr_reader :width, :height

      def initialize(width: -1, height: -1)
        @width = width
        @height = height
      end

      def size
        [@width, @height]
      end

      def key?(_key = nil)
        false
      end

      def mouse?
        false
      end

      def paste?
        false
      end

      def resize?
        true
      end
    end
  end
end
