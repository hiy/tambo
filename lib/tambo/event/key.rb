# frozen_string_literal: true

module Tambo
  module Event
    class Key
      attr_reader :key, :char, :mod

      def initialize(key: 0, char: 0, mod: 0)
        @key = key
        @char = char
        @mod = mod
      end

      def key?(key = nil)
        return true if key.nil?

        @key == key
      end

      def resize?
        false
      end
    end
  end
end
