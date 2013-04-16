require 'test/unit'
require_relative '../generated/Tokens'
require_relative '../generated/Production'

class ProductionTest < Test::Unit::TestCase
  def get_method_call &b
    exp = get_sexp &b
    exp[3]
  end

  def test_rolemethod
    method_call = get_method_call {foo.bar}

    contracts ={}
    roles = {:foo=>{:bar=>[]} }
    production = Production.new(method_call, InterpretationContext.new(roles,contracts,nil,nil))
    assert_equal(Tokens::rolemethod_call, production.type)
  end

  def test_def
    method_call =  get_sexp {
      def self.my_name
        foo.bar
      end
      def foobar(x,y)
        56+x
      end
    }
    contracts ={}
    roles = {:foo=>{:bar=>[]} }
    production = Production.new(method_call, InterpretationContext.new(roles,contracts,nil,nil))
    assert_equal(Tokens::rolemethod_call, production.type)
  end

  def test_call
    method_call = get_method_call {foo.baz}

    contracts ={}
    roles = {:foo=>{:bar=>[]} }
    production = Production.new(method_call, InterpretationContext.new(roles,contracts,nil,nil))
    assert_equal(Tokens::call, production.type)
  end

  def test_indexer
    method_call = get_method_call {foo[0]}

    contracts ={}
    roles = {:foo=>{:bar=>[]} }
    production = Production.new(method_call, InterpretationContext.new(roles,contracts,nil,nil))
    assert_equal(Tokens::indexer, production.type)
  end
end