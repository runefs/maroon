require 'test/unit'
require_relative '../generated/ImmutableQueue'
require_relative '../Test/test_helper'


class ImmutableQueueTest < Test::Unit::TestCase

  def test_sunny
    queue = ImmutableQueue::empty.push 1
    queue = queue.push(2)
    f, queue = queue.pop()
    refute_nil(queue)
    s, queue = queue.pop()
    assert_equal(1, f)
    assert_equal(2, s)
    assert_equal(ImmutableQueue::empty, queue)
  end
end