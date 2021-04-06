# frozen_string_literal: true

module Tambo
  MOD_NONE  = 0
  MOD_SHIFT = 1 << 0
  MOD_CTRL  = 1 << 1
  MOD_ALT   = 1 << 2
  MOD_META  = 1 << 3

  # ASCII control character
  %i[
    KEY_NUL
    KEY_SOH
    KEY_STX
    KEY_ETX
    KEY_EOT
    KEY_ENQ
    KEY_ACK
    KEY_BEL
    KEY_BS
    KEY_TAB
    KEY_LF
    KEY_VT
    KEY_FF
    KEY_CR
    KEY_SO
    KEY_SI
    KEY_DLE
    KEY_DC1
    KEY_DC2
    KEY_DC3
    KEY_DC4
    KEY_NAK
    KEY_SYN
    KEY_ETB
    KEY_CAN
    KEY_EM
    KEY_SUB
    KEY_ESC
    KEY_FS
    KEY_GS
    KEY_RS
    KEY_US
  ].each_with_index do |name, iota|
    const_set(name, iota)
  end

  KEY_DEL = 127

  module Event
    class Key
      attr_reader :key, :char, :mod

      def initialize(key: 0, char: 0, mod: 0)
        @key = key
        @char = char
        @mod = mod
      end

      def key?(key = nil)
        @key == key
      end
    end
  end
end
