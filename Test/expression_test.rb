require_relative '../generated/Expression'
require_relative 'test_helper'

class Expression_test < MiniTest::Unit::TestCase
  include SourceAssertions
  def sunny_test
    block = get_sexp do
      [].each do |r|
        bind :r => :foo
        r.bar
        r.baz
        baz.rolemethod
        self[baz]
      end
      self[0]
    end
    expected = get_sexp do
      [].each do |r|
        temp____foo = @foo
        @foo = r
        self_foo_bar
        foo.baz
        self_baz_rolemethod
        role[baz]
        @foo = temp____foo
      end
      role[0]
    end
    contracts = {}
    roles = {:foo=>{:bar=>nil},:baz=>{:rolemethod=>nil}}
    aliases = {}
    Expression.new(block,InterpretationContext.new(roles,contracts,aliases,:role)).transform
    assert_equal(1,contracts.length)
    assert_equal([:baz],contracts[:foo])
    assert_source_equal(expected,block)

  end
end