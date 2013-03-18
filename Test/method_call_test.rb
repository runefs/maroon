require_relative '../generated/MethodCall'
require_relative 'test_helper'

class Method_call_test  < MiniTest::Unit::TestCase
  def get_method_call &b
    exp = get_sexp &b
    exp[3]
  end
  include SourceAssertions
  def test_adding_to_contracts_no_role
    method_call = get_method_call {foo.bar}

    contracts ={}
    MethodCall.new(method_call,  InterpretationContext.new({},contracts,nil,nil)).rewrite_call?
    assert_nil(contracts[nil]) #wasn't a role
  end

  def test_adding_to_contracts_with_role
    method_call = get_method_call {foo.bar}

    contracts ={}
    roles = Hash.new
    roles[:foo] = Hash.new
    MethodCall.new(method_call, InterpretationContext.new(roles,contracts,nil,nil)).rewrite_call?
    assert_equal(1,contracts.length)
    assert_equal(1, contracts[:foo].length)
    assert_equal(1, contracts[:foo][:bar])
  end
  def test_role_methods_not_added_to_contracts
    method_call = get_method_call {foo.bar}

    contracts ={}
    roles = Hash.new
    roles[:foo] = {:bar => nil}
    MethodCall.new(method_call,  InterpretationContext.new(roles,contracts,nil,nil)).rewrite_call?
    assert_equal(0,contracts.length)
    assert_source_equal(get_method_call {self_foo_bar},method_call)
  end

  def test_contract_and_bind
    block =get_sexp do [].each do |r|
        temp____foo = @foo
        @foo = r
        r.bar
        foo.baz
      @foo = temp____foo
      end
    end

    contracts ={}
    roles = {:foo=> {:bar => nil},:role=>{}}
    methodcall1 = block[3][3][3]
    methodcall2 = block[3][3][4]
    expected1 = get_method_call {self_foo_bar}
    expected2 = get_method_call {foo.baz}

    MethodCall.new(methodcall1, InterpretationContext.new(roles,contracts,{:r=>:foo},:role)).rewrite_call?
    MethodCall.new(methodcall2, InterpretationContext.new(roles,contracts,{:r=>:foo},:role)).rewrite_call?

    assert_source_equal(expected2,methodcall2)
    assert_source_equal(expected1,methodcall1)
    assert_equal(1,contracts.length)
    assert_equal(1,contracts[:foo].length)
    assert_equal(1,contracts[:foo][:baz])
    assert_nil(contracts[:bar])
  end
  def test_index_contracts
    methodcall = (get_sexp do
      role[boo]
    end)[3]

    contracts = {}
    roles = {:foo=>{:bar=>nil},:baz=>{:rolemethod=>nil},:role=>{}}
    aliases = {}
    interpretation_context = InterpretationContext.new(roles,contracts,aliases,:role)
    mc = MethodCall.new(methodcall, interpretation_context)
    mc.rewrite_call?

    assert_equal(1,contracts.length)
    assert_equal(1,interpretation_context.contracts[:role].length)
    assert_equal(1,interpretation_context.contracts[:role][:[]])
  end
end