# frozen_string_literal: true

module Tambo
  module Event
    class Resize
      def initialize; end

      def key?(_key = nil)
        false
      end

      def resize?
        true
      end
    end
  end
end
