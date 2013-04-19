require 'test/unit'
require_relative '../generated/MethodInfo'
require 'ripper'
require_relative 'test_helper'

class MethodInfoTest #< Test::Unit::TestCase
  include SourceAssertions
  def test_simple
    block = get_sexp do |a,b|
      p 'this is a test'
    end
    source = MethodInfo.new(false,block,true).build_as_context_method("name",InterpretationContext.new({},{},{},nil))
    expected = %{def name(a,b)
       p("this is a test")
    end
}
    assert_source_equal(expected,source)
  end
  def test_class_method
    block = get_sexp do |a,b|
      p 'this is a test'
    end
    source = MethodInfo.new(self,block,true).build_as_context_method("name",InterpretationContext.new({},{},{},nil))
    expected = %{def self.name(a,b)
       p("this is a test")
    end
}
    assert_source_equal(expected,source)
  end

  def test_splat_argument
    block = get_sexp do |a,*b|
      p 'this is a test'
    end
    source = MethodInfo.new(nil,block,true).build_as_context_method("name",InterpretationContext.new({},{},{},nil))
    expected = %{def name(a,*b)
       p("this is a test")
    end
}
    assert_source_equal(expected,source)
  end

  def test_block_argument
    block = get_sexp do |a,b|
      p 'this is a test'
    end
    source = MethodInfo.new({:block=>:block},block,true)
    source = source.build_as_context_method("name",InterpretationContext.new({},{},{},nil))
    expected = %{def name(a,b,&block)
       p("this is a test")
    end
}
    assert_source_equal(expected,source)
  end
  def test_block_argument_class_method
    block = (get_sexp { |a,*b|
      p 'is a test'    })
    source = MethodInfo.new({:block=>:block,:self=>self},block,true).build_as_context_method("name",InterpretationContext.new({},{},{},nil))
    expected = %{def self.name(a,*b,&block)
       p("this is a test")
    end
}
    assert_source_equal(expected,source)
  end
end