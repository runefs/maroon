require_relative '../generated/MethodDefinition'
require_relative 'test_helper'

class Expression_test < MiniTest::Unit::TestCase
  include SourceAssertions
  def get_context
    contracts = {}
    roles = {:foo=>{:bar=>nil},:baz=>{:rolemethod=>nil},:role=>{}}
    aliases = {}
    InterpretationContext.new(roles,contracts,aliases,:role)
  end
  def assert_transform(expected,block)
    ctx = get_context
    MethodDefinition.new(block,ctx).transform
    assert_source_equal(expected,block)
    ctx
  end
  def test_method_call
    block = (get_sexp do
        baz.rolemethod
    end)[3]
    expected = (get_sexp do
      self_baz_rolemethod
    end)[3]
    assert_transform(expected,block)
  end
  def test_index
    block = (get_sexp do
      self[0]
    end)[3]
    expected = (get_sexp do
      role[0]
    end)[3]
    ctx = assert_transform(expected,block)
    assert_equal(1,ctx.contracts[:role][:[]])
  end
  def test_bind
    block =  get_sexp do [].each do |r|
      bind :r=>:foo
      r.bar
      foo.baz
    end
    end
    expected = (get_sexp do
      [].each do |r|
        temp____foo = @foo
        @foo = r
        self_foo_bar
        foo.baz
        @foo = temp____foo
      end
    end)
    assert_transform(expected,block)
  end

  def test_sunny
    block = get_sexp do
      [].each do |r|
        bind :r => :foo
        r.bar
        r.baz
        baz.rolemethod
        self[boo]
      end
      self[0]
    end
    expected = (get_sexp do
      [].each do |r|
        temp____foo = @foo
        @foo = r
        self_foo_bar
        r.baz
        self_baz_rolemethod
        role[boo]
        @foo = temp____foo
      end
      role[0]
    end)

    interpretation_context = get_context
    MethodDefinition.new(block,interpretation_context).transform
    assert_source_equal(expected,block)
    contracts = interpretation_context.contracts
    assert_equal(2,contracts.length)
    assert(contracts[:role].has_key? :[])
    assert_equal(1,contracts[:role].length)
    assert(contracts[:foo].has_key? :baz)
    assert_nil(contracts[:baz])
  end

  def test_nested_lambda
    block = lambda {
      lambda {baz.rolemethod}}.call.to_sexp
    expected = lambda {
      lambda {self_baz_rolemethod}}.call.to_sexp

    assert_transform(expected,block)
  end

end