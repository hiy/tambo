# frozen_string_literal: true

module Tambo
  require "pty"

  class Infocmp
    attr_reader :info

    class FormatError < StandardError; end

    class Info
      attr_accessor :name, :description, :booleans, :numbers, :strings, :aliases

      def initialize
        @name = ""
        @description = ""
        @numbers = {}
        @strings = {}
        @booleans = {}
        @aliases = []
      end
    end

    def initialize(name)
      @term_name = name
    end

    def execute
      lines = exec_command
      parse_line(lines)
    end

    private

    def parse_line(lines)
      info = Infocmp::Info.new
      # Drop empty line
      lines.delete("")
      # Drop first line comment.
      _ = lines.shift if lines.first =~ /^#/
      # Drop header last comma.
      header = lines.shift
      header = header.sub(/,$/, "")

      names = header.split("|")
      info.name = names.shift
      info.description = names.pop || ""
      info.aliases = names

      lines.each do |line|
        raise FormatError, "Format Error: #{line}" if line =~ /^\\t.*,$/

        line = line[1..-2]
        key, value = line.split(/=/, 2)

        if value
          info.strings[key] = unescape(value)
          next
        end

        key, value = line.split(/#/, 2)
        if value
          info.numbers[key] = value.to_i
          next
        end

        info.booleans[key] = true
      end

      info
    end

    def exec_command
      lines = []
      # -x treat unknown capabilities as user-defined
      # -L use long names
      # -1 print single-column
      PTY.spawn("infocmp -xL1 #{@term_name}") do |pty_out, pty_in, _pid|
        pty_in.close
        while l = pty_out.gets
          lines << l.chomp
        end
      end
      lines
    end

    def unescape(str)
      buf = ::StringIO.new
      mode = { none: 0, control: 1, escaped: 2 }
      current_mode = mode[:none]
      skip_indexes = []

      str.each_char.with_index do |char, i|
        next if skip_indexes.include?(i)

        case current_mode
        when mode[:none]
          case char
          when '\\'
            current_mode = mode[:escaped]
          when "^"
            current_mode = mode[:control]
          else
            buf.write(char)
          end
        when mode[:control]
          buf.write((char.ord ^ 1 << 6).chr)
          current_mode = mode[:none]
        when mode[:escaped]
          case char
          when "E", "e"
            buf.write(0x1b.chr)
          when "0", "1", "2", "3", "4", "5", "6", "7"
            if str[i + 2] &&
               str[i + 1].ord >= "0".ord &&
               str[i + 1].ord <= "7".ord &&
               str[i + 2].ord >= "0".ord &&
               str[i + 2].ord <= "7".ord
              ord = ((char.ord - "0".ord) * 64) +
                    ((str[i + 1].ord - "0".ord) * 8) +
                    (str[i + 2].ord - "0".ord)
              buf.write(ord.chr)
              skip_indexes.push(i + 1, i + 2)
            elsif char.ord == "0".ord
              buf.write(0.chr)
            end
          when "n"
            buf.write("\n")
          when "r"
            buf.write("\r")
          when "t"
            buf.write("\t")
          when "b"
            buf.write("\b")
          when "f"
            buf.write("\f")
          when "s"
            buf.write(" ")
          else
            buf.write(char)
          end

          current_mode = mode[:none]
        end
      end

      buf.rewind
      buf.read
    end
  end
end
