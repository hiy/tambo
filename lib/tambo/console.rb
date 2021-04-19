# frozen_string_literal: true

module Tambo
  require "forwardable"
  require_relative "platform"

  class Console
    extend Forwardable

    def_delegators :@screen,
                   :style,
                   :style=,
                   :write,
                   :show,
                   :clear,
                   :close,
                   :sync,
                   :poll_event,
                   :size,
                   :colors,
                   :beep

    def initialize
      @screen =
        if Platform.darwin?
          Tambo::Screen::Darwin.new
        elsif Platform.linux?
          Tambo::Screen::Linux.new
          raise "unsupported platform"
        elsif Platform.windows?
          Tambo::Screen::Windows.new
          raise "unsupported platform"
        else
          raise "unsupported platform"
        end
    end
  end
end
