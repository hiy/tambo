# frozen_string_literal: true

module Tambo
  module Logger
    require "fileutils"
    FileUtils.mkdir_p("#{Dir.pwd}/log")

    def self.clear_debug_log
      File.open("#{Dir.pwd}/log/debug.log", "w") do |f|
        f.write ""
      end
    end

    def self.debug(str)
      File.open("#{Dir.pwd}/log/debug.log", "a") do |f|
        f.write "|#{str}|\n"
      end
    end

    def self.debug_raw_buf(str)
      File.open("#{Dir.pwd}/log/debug_raw_buf.log", "w") do |f|
        f.write str
      end
    end
  end
end
