require 'test/unit'
require_relative '../generated/ImmutableQueue'
require_relative '../generated/ImmutableStack'

ImmutableQueue.new nil,nil

class ImmutableQueueTest < Test::Unit::TestCase

  def test_sunny
    queue = ImmutableQueue.new(ImmutableStack.new(1,nil),nil)
    queue = queue.push(2)
    f,queue = queue.pop()
    refute_nil(queue)
    s,queue = queue.pop()
    assert_equal(1,f)
    assert_equal(2,s)
    assert_equal(ImmutableQueue::empty, queue)
  end
end