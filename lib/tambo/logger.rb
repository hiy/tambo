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

    def self.dump_to_yaml(obj)
      File.open("#{Dir.pwd}/log/terminfo.yaml", "w") do |f|
        f.write obj.to_yaml
      end
    end

    def self.backtrace(error)
      File.open("#{Dir.pwd}/log/debug.log", "a") do |f|
        f.write error
        error.backtrace.each do |str|
          f.write "#{str}\n"
        end
      end
    end
  end
end
