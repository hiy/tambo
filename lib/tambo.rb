# frozen_string_literal: true

require "stringio"
require "unicode/display_width"

require_relative "tambo/version"

module Tambo
  class Error < StandardError; end
  require "tambo/constants/key"

  require "tambo/screen/io"
  require "tambo/event/scanner"
  require "tambo/event/key"
  require "tambo/logger"
  require "tambo/cell"
  require "tambo/infocmp"
  require "tambo/terminfo"
  require "tambo/platform"
  require "tambo/screen/darwin"
  require "tambo/console"
  require "tambo/text"
end
