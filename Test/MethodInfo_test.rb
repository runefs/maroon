require 'test/unit'
require_relative '../generated/MethodInfo'
require 'ripper'
require_relative 'test_helper'

class MethodInfoTest < Test::Unit::TestCase
  include SourceAssertions
   def get_def(&b)
     (get_sexp &b).detect do |exp|
       exp[0] == :defn || exp[0] == :defs
     end
   end

  def test_simple
    block = get_def  do
      def name (a, b)
        p 'this is a test'
      end
    end

    source = MethodInfo.new( block,nil,false).build_as_context_method( InterpretationContext.new({}, {}, {}, nil))
    expected ='def name(a,b)    p("this is a test") end'
    assert_source_equal(expected, source)
  end

  def test_rolemethod
    block = get_def  do
      def name (a, b)
        foo.bar
      end
    end

    source = MethodInfo.new( block,nil,false).build_as_context_method( InterpretationContext.new({:foo=>{:bar=>[]}}, {}, {}, nil))
    expected ='def name(a,b)    self_foo_bar end'
    assert_source_equal(expected, source)
  end

  def test_class_method
    block = get_def do
      def self.name(a, b)
        p 'this is a test'
      end
    end

    source = MethodInfo.new( block,nil,false).build_as_context_method( InterpretationContext.new({}, {}, {}, nil))
    expected = 'def self.name(a,b)  p("this is a test") end'

    assert_source_equal(expected, source)
  end

  def test_splat_argument
    block = get_def do
      def name (a, *b)
      p 'this is a test'
      end
    end
    source = MethodInfo.new( block,nil,false).build_as_context_method( InterpretationContext.new({}, {}, {}, nil))
    expected = 'def name(a,*b) p("this is a test") end'
    assert_source_equal(expected, source)
  end

  def test_block_argument
    block = get_def do
     def name(a, b,&block)
      p 'this is a test'
     end
    end

    source = MethodInfo.new( block,nil,false)
    source = source.build_as_context_method(InterpretationContext.new({}, {}, {}, nil))
    expected = 'def name(a,b,&block)    p("this is a test")  end'

    assert_source_equal(expected, source)
  end

  def test_block_argument_class_method
    block = get_def do
      def self.name(a, *b,&block)
        p 'is a test'
      end
    end
    source = MethodInfo.new( block,nil,false).build_as_context_method( InterpretationContext.new({}, {}, {}, nil))
    expected = 'def self.name(a,*b,&block) p("is a test") end'
    assert_source_equal(expected, source)
  end
end