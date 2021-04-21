# frozen_string_literal: true

require "stringio"
require "unicode/display_width"

require_relative "tambo/version"

module Tambo
  class Error < StandardError; end
  require_relative "tambo/constants/color"
  require_relative "tambo/constants/key"
  require_relative "tambo/style"
  require_relative "tambo/color"
  require_relative "tambo/screen/io"
  require_relative "tambo/event/scanner"
  require_relative "tambo/event/key"
  require_relative "tambo/event/resize"
  require_relative "tambo/logger"
  require_relative "tambo/cell"
  require_relative "tambo/cell_buffer"
  require_relative "tambo/infocmp"
  require_relative "tambo/terminfo"
  require_relative "tambo/platform"
  require_relative "tambo/console"
  require_relative "tambo/text"

  Tambo::Screen.autoload :Darwin, "tambo/screen/darwin"
end
