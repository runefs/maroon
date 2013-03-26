require 'test/unit'
require_relative '../generated/MethodInfo'
require 'ripper'
require_relative 'test_helper'

class MethodInfoTest < Test::Unit::TestCase
  include SourceAssertions
  def test_simple
    block = get_sexp do |a,b|
      p "this is a test"
    end
    source = MethodInfoCtx.new(false,block).build_as_context_method("name",InterpretationContext.new({},{},{},nil))
    expected = %{def name(a,b)
       p("this is a test")
    end
}
    assert_source_equal(expected,source)
  end
  def test_class_method
    block = get_sexp do |a,b|
      p "this is a test"
    end
    source = MethodInfoCtx.new(self,block).build_as_context_method("name",InterpretationContext.new({},{},{},nil))
    expected = %{def self.name(a,b)
       p("this is a test")
    end
}
    assert_source_equal(expected,source)
  end

  def test_splat_argument
    block = get_sexp do |a,*b|
      p "this is a test"
    end
    source = MethodInfoCtx.new(nil,block).build_as_context_method("name",InterpretationContext.new({},{},{},nil))
    expected = %{def name(a,*b)
       p("this is a test")
    end
}
    assert_source_equal(expected,source)
  end

  def test_block_argument
    block = get_sexp do |a,b|
      p "this is a test"
    end
    source = MethodInfoCtx.new({:block=>:block},block).build_as_context_method("name",InterpretationContext.new({},{},{},nil))
    expected = %{def name(a,b,&block)
       p("this is a test")
    end
}
    assert_source_equal(expected,source)
  end
  def test_block_argument_class_method
    block = get_sexp do |a,*b|
      p "this is a test"
    end
    source = MethodInfoCtx.new({:block=>:block,:self=>self},block).build_as_context_method("name",InterpretationContext.new({},{},{},nil))
    expected = %{def self.name(a,*b,&block)
       p("this is a test")
    end
}
    assert_source_equal(expected,source)
  end
end