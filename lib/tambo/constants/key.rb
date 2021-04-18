# frozen_string_literal: true

module Tambo
  ModNone  = 0
  ModShift = 1 << 0
  ModCtrl  = 1 << 1
  ModAlt   = 1 << 2
  ModMeta  = 1 << 3

  # ASCII control character
  %i[KeyNUL
     KeySOH
     KeySTX
     KeyETX
     KeyEOT
     KeyENQ
     KeyACK
     KeyBEL
     KeyBS
     KeyTAB
     KeyLF
     KeyVT
     KeyFF
     KeyCR
     KeySO
     KeySI
     KeyDLE
     KeyDC1
     KeyDC2
     KeyDC3
     KeyDC4
     KeyNAK
     KeySYN
     KeyETB
     KeyCAN
     KeyEM
     KeySUB
     KeyESC
     KeyFS
     KeyGS
     KeyRS
     KeyUS].each_with_index do |name, index|
    const_set(name, index)
  end

  KeyDEL = 127

  KeyEscape = KeyESC
end
