require 'test/unit'
require_relative '../generated/Tokens'
require_relative '../generated/Production'
require_relative 'test_helper'

class ProductionTest < Test::Unit::TestCase
  def get_method_call &b
    exp = get_sexp &b
    exp[3]
  end

  def get_context(roles={},contracts={},role_aliases={},defining=nil,private_interactions= {})
    InterpretationContext.new(roles, contracts, role_aliases,defining,private_interactions)
  end

  def test_rolemethod
    method_call = get_method_call { foo.bar }

    production = get_production(method_call)
    type = production.type
    assert_equal(Tokens::rolemethod_call, type)
  end

  def get_production(method_call)
    contracts ={}
    roles = {:foo => {:bar => []}}
    AbstractSyntaxTree.new(method_call, get_context(roles, contracts))
  end

  def test_call
    method_call = get_method_call { foo.baz }

    production = get_production(method_call)
    type = production.type

    assert_equal(Tokens::call, type)
  end

  def test_indexer
    method_call = get_method_call { foo[0] }

    production = get_production(method_call)
    type = production.type

    assert_equal(Tokens::indexer, type)
  end
end