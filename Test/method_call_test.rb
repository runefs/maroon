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
    MethodCall.new(method_call, {},contracts,nil).rewrite_call?
    assert_equal(1,contracts.length)
    assert_equal([:bar], contracts[nil]) #wasn't a role
  end

  def test_adding_to_contracts_with_role
    method_call = get_method_call {foo.bar}

    contracts ={}
    roles = Hash.new
    roles[:foo] = Hash.new
    MethodCall.new(method_call, roles,contracts,nil).rewrite_call?
    assert_equal(1,contracts.length)
    assert_equal([:bar], contracts[:foo]) #wasn't a role
  end
  def test_role_methods_not_added_to_contracts
    method_call = get_method_call {foo.bar}

    contracts ={}
    roles = Hash.new
    roles[:foo] = {:bar => nil}
    MethodCall.new(method_call, roles,contracts,nil).rewrite_call?
    assert_equal(0,contracts.length)
    assert_source_equal(get_method_call {self_foo_bar},method_call)
  end
  #integrating bind and method call
  def test_contract_and_bind
    block =get_sexp do [].each do |r|
        bind :r=>:foo
        r.bar
        foo.baz
      end
    end
    Bind.new(:r,:foo,block[3][3]).execute

    contracts ={}
    roles = Hash.new
    roles[:foo] = {:bar => nil}
    methodcall1 = block[3][3][3]
    methodcall2 = block[3][3][4]
    expected1 = get_method_call {self_foo_bar}
    expected2 = get_method_call {foo.baz}

    MethodCall.new(methodcall1, roles,contracts,{:r=>:foo}).rewrite_call?
    MethodCall.new(methodcall2, roles,contracts,{:r=>:foo}).rewrite_call?

    assert_source_equal(expected2,methodcall2)
    assert_source_equal(expected1,methodcall1)
    assert_equal(1,contracts.length)
    assert_equal([:baz],contracts[:foo])
    assert_nil(contracts[:bar])

  end

end