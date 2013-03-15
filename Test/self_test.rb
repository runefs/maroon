require_relative '../generated/self'
require_relative 'test_helper'

require 'ruby2ruby'

class Self_test < MiniTest::Unit::TestCase
  include SourceAssertions
  def assert_self(abstract_syntax_tree, defining_role)
     assert_equal(:call,abstract_syntax_tree[0])
     assert_nil(abstract_syntax_tree[1])
     assert_equal(defining_role, abstract_syntax_tree[2])
     assert_instance_of(Sexp,abstract_syntax_tree[3])
     assert_equal(abstract_syntax_tree[3][0], :arglist)
  end
  def test_sunny
    ast = (get_sexp { self.bar })[3]
    defining_role = :role

    Self.new(ast,defining_role).execute

    expected = (get_sexp { role.bar })[3]
    assert_source_equal(expected,ast)
  end
  def test_indexer
    ast = (get_sexp {self[0]})[3]

    Self.new(ast,:role).execute

    expected = (get_sexp { role[0] })[3]
    assert_source_equal(expected,ast)
  end
  def test_as_index
    ast = (get_sexp {bar[self]})[3]

    Self.new(ast,:role).execute

    expected = (get_sexp { bar[role] })[3]
    refute_nil(ast)
    refute_equal(0,ast.length)
    assert_source_equal(expected,ast)
  end
end