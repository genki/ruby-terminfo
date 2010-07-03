require 'test/unit'
require 'pty'
require 'terminfo'

class TestTermInfoWinsize < Test::Unit::TestCase
  def test_winsize
    PTY.open {|m, s|
      TermInfo.tiocswinsz(s, 80, 25)
      assert_equal([80,25], TermInfo.tiocgwinsz(s))
      TermInfo.tiocswinsz(s, 200, 300)
      assert_equal([200,300], TermInfo.tiocgwinsz(s))
    }
  end
end
