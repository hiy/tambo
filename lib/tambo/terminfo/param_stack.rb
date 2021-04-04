# frozen_string_literal: true

module Tambo
  class Terminfo
    class ParamStack < Array
      class Element
        attr_accessor :value

        def initialize(value)
          @value = value
        end

        def integer?
          @value.is_a?(Numeric)
        end

        def string?
          @value.is_a?(String)
        end
      end

      def push(s)
        self << Element.new(s)
        self
      end

      def pop
        if any?
          el = super
          return el.value
        end
        ""
      end

      def pop_int
        if any?
          el = public_method(:pop).super_method.call
          if el.integer?
            return el.value
          elsif el.string?
            begin
              return el.value.to_i
            rescue StandardError
              return el.value[0].to_i if el.value.size >= 1
            end
          end
        end

        0
      end

      def pop_bool
        if any?
          el = public_method(:pop).super_method.call
          if el.string?
            return true if el.value == "1"

            return false
          elsif el.value == 1
            return true
          else
            return false
          end
        end

        false
      end

      def push_int(i)
        self << Element.new(i)
        self
      end

      def push_bool(i)
        return push_int(1) if i

        push_int(0)
        self
      end
    end
  end
end
