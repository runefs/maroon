require_relative '../generated/bind'
require_relative 'test_helper'

class Bind_test < MiniTest::Unit::TestCase
  def test_sunny
    block = Sexp.new
    Bind.new(:role, :alias, block).execute
    assert_equal(nil, block[0])
    assert_equal(:@alias, block[1][2][1])
    assert_equal(:role, block[2][2][1])
    assert_equal(:@alias, block.last()[1])
  end
end