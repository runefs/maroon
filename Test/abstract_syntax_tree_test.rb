require 'test/unit'
require_relative '../generated/Tokens'
require_relative '../generated/AbstractSyntaxTree'
require_relative 'test_helper'

class AbstractSyntaxTreeTest < Test::Unit::TestCase

  def get_type_of_production(&b)
    contracts ={}
    roles = {:foo => {:bar => []}}
    interpretation_context = InterpretationContext.new(roles, contracts, nil,nil,nil)

    exp = get_sexp &b
    method_call = exp[3]
    production = AbstractSyntaxTree.new(method_call, interpretation_context )
    production.type
  end

  def test_rolemethod
    type = get_type_of_production { foo.bar }
    assert_equal(Tokens::rolemethod_call, type)
  end

  def test_call
    type = get_type_of_production  { foo.baz }
    assert_equal(Tokens::call, type)
  end

  def test_initializer
    type = get_type_of_production { AbstractSyntaxTreeTest.new(nil) }
    assert_equal(Tokens::initializer, type)
  end

  def test_indexer
    type = get_type_of_production  { foo[0] }
    assert_equal(Tokens::indexer, type)
  end
end