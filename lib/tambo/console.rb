# frozen_string_literal: true

module Tambo
  require "forwardable"
  require_relative "platform"

  class Console
    extend Forwardable

    def_delegators :@screen,
                   :clear,
                   :close,
                   :size,
                   :poll_event,
                   :resize,
                   :beep,
                   :sync,
                   :show,
                   :colors,
                   :write

    def initialize
      @screen =
        if Platform.darwin?
          Tambo::Screen::Darwin.new
        else
          raise "unsupported platform"
        end
    end
  end
end
