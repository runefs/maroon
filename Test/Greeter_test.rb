require 'test/unit'
require '../lib/maroon.rb'
require '../lib/maroon/kernel.rb'

##
# General comment
# it's hopeless to test for the actual source. It should be the syntax tree rather than the source
# it's the semantics that are important not the formatted source!!
##

context :Greet_Someone, :greet do
  role :greeter do
    welcome do
      self.greeting
    end
  end

  role :greeted do
  end

  greet do
    "#{greeter.name}: \"#{greeter.welcome}, #{greeted.name}!\""
  end
end

context :Greet_Someone2, :greet do
  role :greeter do
    welcome do
      self.greeting
    end
  end

  role :greeted do
  end

  greet do |msg|
    a = "#{greeter.name}: \"#{greeter.welcome}, #{greeted.name}!\" #{msg}"
    p a
    a
  end
end

class Person
  attr_accessor :name
  attr_accessor :greeting
end


class Greet_Someone
  def initialize(greeter, greeted)
    @greeter = greeter
    @greeted = greeted
  end
end

class Greet_Someone2
  def initialize(greeter, greeted)
    @greeter = greeter
    @greeted = greeted
  end
end

class BasicTests < Test::Unit::TestCase

  def test_define_context
    name = :MyContext
    ctx,source = Context::define name do end
    assert_equal(ctx.name, "Kernel::#{name}")
    assert_equal(source,"class #{name}\r\n\n\n  private\n\n\n\r\nend")
  end

  def test_base_class
    name = :MyDerivedContext
    ctx,source = context name, Person do end
    obj = MyDerivedContext.new
    obj.name = name
    assert_equal(ctx.name, "Kernel::#{name}")
    assert_not_nil(obj.name)
    assert((obj.class < Person), 'Object is not a Person')
    assert_equal(name, obj.name)
  end

  def test_define_role
    name,role_name = :MyContextWithRole,:my_role
    ctx,source = Context::define name do
      role role_name do
        role_go_do do

        end
      end
    end
    assert_not_nil(ctx)
    assert_equal(ctx.name, "Kernel::#{name}")
    assert_equal("class #{name}\r\n\n@#{role_name}\n\n  private\ndef #{role_name};@#{role_name} end\n\n  \ndef self_#{role_name}_role_go_do \n end\n\n\r\nend",source)
  end

  def test_bind
    name,other_name = :MyContextUsingBind,:other_role
    ctx,source = Context::define name do
      role other_name do
          plus_one do
             (self + 1)
          end
      end
      go_do do
             a = Array.new
             [1,2].each do |e|
                  bind e => :other_role
                  a << e.plus_one
             end
          a
       end
    end
    arr = MyContextUsingBind.new.go_do
    assert_not_nil(ctx)
    assert_equal(ctx.name, "Kernel::#{name}")
    assert_equal("class #{name}\r\n  \ndef go_do \na = Array.new\n  [1, 2].each do |e|\n    temp____#{other_name} = @#{other_name}\n    @#{other_name} = e\n    (a << self_#{other_name}_plus_one)\n    @#{other_name} = temp____#{other_name}\n  end\n  a\n end\n\n@#{other_name}\n\n  private\ndef #{other_name};@#{other_name} end\n\n  \ndef self_#{other_name}_plus_one \n(#{other_name} + 1)  end\n\n\r\nend",source)
    assert_equal(2,arr[0])
    assert_equal(3,arr[1])
  end
end

class TestExamples < Test::Unit::TestCase
   def test_greeter
     p1 = Person.new
     p1.name = 'Bob'
     p1.greeting = 'Hello'

     p2 = Person.new
     p2.name = 'World!'
     p2.greeting = 'Greetings'

     #Execute is automagically created for the default interaction (specified by the second argument in context :Greet_Someone, :greet do)
     #Executes constructs a context object and calls the default interaction on this object
     res1 = Greet_Someone.call p1, p2
     res2 = Greet_Someone.new(p2, p1).greet
     res3 = Greet_Someone.new(p2, p1).call
     assert_equal(res1,"#{p1.name}: \"#{p1.greeting}, #{p2.name}!\"")
     assert_equal(res1,Greet_Someone.new(p1, p2).greet) #verifies default action
     #constructs a Greet_Someone context object and executes greet.
     assert_equal(res2,"#{p2.name}: \"#{p2.greeting}, #{p1.name}!\"")
     assert_equal(res2,res3)
   end
end


class TestExamples < Test::Unit::TestCase
  def test_greeter
    p1 = Person.new
    p1.name = 'Bob'
    p1.greeting = 'Hello'

    p2 = Person.new
    p2.name = 'World!'
    p2.greeting = 'Greetings'

    message = ' Nice weather, don\'t you think?'
    res1 = Greet_Someone2.call p1, p2, message
    res2 = Greet_Someone2.new(p2, p1).greet message
    res3 = Greet_Someone2.new(p2, p1).call message
    assert_equal(res1,"#{p1.name}: \"#{p1.greeting}, #{p2.name}!\" #{message}")
    assert_equal(res1,Greet_Someone2.new(p1, p2).greet(message)) #verifies default action
    #constructs a Greet_Someone context object and executes greet.
    assert_equal(res2,"#{p2.name}: \"#{p2.greeting}, #{p1.name}!\" #{message}")
    assert_equal(res2,res3)
  end
end



