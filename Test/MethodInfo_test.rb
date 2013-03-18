require 'test/unit'
require_relative '../generated/MethodInfoCtx'
require 'ripper'
require_relative 'test_helper'

class MethodInfoTest < Test::Unit::TestCase
  include SourceAssertions
  def test_simple
    block = get_sexp do |a,b|
      p "this is a test"
    end
    source = MethodInfoCtx.new(block).build_as_context_method("name",InterpretationContext.new({},{},{},nil))
    expected = %{def name(a,b)
       p("this is a test")
    end
}
    assert_source_equal(expected,source)
  end
end