require 'test/unit'
require_relative '../generated/ImmutableStack'

ImmutableStack.new nil,nil

class Stack_Test < Test::Unit::TestCase

  def test_push_pop
    stack = ImmutableStack.new(1,nil)
    stack = stack.push 2
    f,stack = stack.pop
    s,stack = stack.pop
    assert_equal(2,f)
    assert_equal(1,s)
    assert_nil(stack)
  end
end