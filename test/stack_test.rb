require_relative '../generated/immutable_stack'
# require_relative '../lib/immutable_stack'

require_relative '../test/test_helper'

class Stack_Test < Minitest::Test

  def test_push_pop
    stack = ImmutableStack.empty.push(1)
    stack = stack.push 2
    f, stack = stack.pop
    s, stack = stack.pop
    assert_equal(2, f)
    assert_equal(1, s)
    assert_equal(stack, ImmutableStack::empty)
  end
end