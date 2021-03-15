module Tambo
  require 'forwardable'
  class Console
    extend Forwardable

    def_delegators :@screen,
                   :clear,
                   :close,
                   :size,
                   :poll_event

    def initialize
      @screen = Screen.new
    end
  end
end