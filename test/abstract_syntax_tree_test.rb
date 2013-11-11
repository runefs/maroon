# test generated lib
require_relative '../generated/tokens'
require_relative '../generated/abstract_syntax_tree'

# test core lib
# require_relative '../lib/tokens'
# require_relative '../lib/abstract_syntax_tree'

require_relative 'test_helper'

class AbstractSyntaxTreeTest < Minitest::Test

  def get_type_of_production(&b)
    contracts ={}
    roles = {:foo => Role.new(:foo,__LINE__,__FILE__) }
    roles[:foo].methods[:bar] = {}
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

  def test_block_with_bind
    type = get_type_of_production  { [].each{|role|
      bind :role => :foo
    } }
    assert_equal(Tokens::block_with_bind, type)
  end

end