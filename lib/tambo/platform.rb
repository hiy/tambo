# frozen_string_literal: true

module Tambo
  module Platform
    def self.windows?
      /mswin|msys|mingw|cygwin|bccwin|wince|emc/.match?(RbConfig::CONFIG["host_os"])
    end

    def self.darwin?
      /darwin|mac os/.match?(RbConfig::CONFIG["host_os"])
    end

    def self.linux?
      /linux/.match?(RbConfig::CONFIG["host_os"])
    end

    def self.unix?
      /solaris|bsd/.match?(RbConfig::CONFIG["host_os"])
    end

    def self.name
      case RbConfig::CONFIG["host_os"]
      when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
        :windows
      when /darwin|mac os/
        :darwin
      when /linux/
        :linux
      when /solaris|bsd/
        :unix
      else
        :stub
      end
    end
  end
end
