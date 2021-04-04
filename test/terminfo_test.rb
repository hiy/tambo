# frozen_string_literal: true

require "test_helper"

class TerminfoTest < Minitest::Test
  def test_tputs; end

  def test_tperm
    params = {
      set_fg: "\x1b[%?%p1%{8}%<%t3%p1%d%e%p1%{16}%<%t9%p1%{8}%-%d%e38;5;%p1%d%;m",
      mouse_mode: "%?%p1%{1}%=%t%'h'%Pa%e%'l'%Pa%;\x1b[?1000%ga%c\x1b[?1003%ga%c\x1b[?1006%ga%c"
    }

    ti = Tambo::Terminfo.new(ENV["TERM"])
    parms = (0..7).map { |color| ti.tparm(params[:set_fg], color) }
    assert       ["\e[30m", "\e[34m", "\e[32m", "\e[36m", "\e[31m", "\e[35m", "\e[33m", "\e[37m"], parms
    assert_equal "\x1b[97m", ti.tparm(params[:set_fg], 15)
    assert_equal "\x1b[38;5;200m", ti.tparm(params[:set_fg], 200)
    assert_equal "\x1b[?1000h\x1b[?1003h\x1b[?1006h", ti.tparm(params[:mouse_mode], 1)
    assert_equal "\x1b[?1000l\x1b[?1003l\x1b[?1006l", ti.tparm(params[:mouse_mode], 0)

    # setabf
    assert_equal "\e[48;5;1m", ti.tparm("\e[48;5;%p1%dm", 1)

    # int constants
    assert_equal "21", ti.tparm("%{1}%{2}%d%d")

    # op_int
    assert_equal "123233", ti.tparm("%p1%d%p2%d%p3%d%i%p1%d%p2%d%p3%d", 1, 2, 3)

    # conditionals
    assert_equal(
      "\e[31m",
      ti.tparm("\e[%?%p1%{8}%<%t3%p1%d%e%p1%{16}%<%t9%p1%{8}%-%d%e38;5;%p1%d%;m", 1)
    )

    assert_equal(
      "\e[90m",
      ti.tparm(
        "\e[%?%p1%{8}%<%t3%p1%d%e%p1%{16}%<%t9%p1%{8}%-%d%e38;5;%p1%d%;m", 8
      )
    )

    assert_equal(
      "\e[38;5;42m",
      ti.tparm(
        "\e[%?%p1%{8}%<%t3%p1%d%e%p1%{16}%<%t9%p1%{8}%-%d%e38;5;%p1%d%;m", 42
      )
    )
  end

  def test_tgoto
    # assert_equal ti.tgoto(7, 9), "\x1b[10;8H"
  end
end
