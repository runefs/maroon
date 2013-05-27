#Thanks to Ted Milken for updating the original example
require_relative '../base/maroon_base.rb'
#require_relative '../base/maroon/kernel.rb'
#require_relative '../base/maroon/contracts.rb'

class Person
  attr_accessor :name
  attr_accessor :greeting
end

Context.define :Greet_Someone do
  role :greeter do
    def welcome
      greeter.greeting
    end
  end

  role :greeted do
  end

  def greet
    %{#{greeter.name}: "#{greeter.welcome}, #{greeted.name}!"}
  end

  def initialize(greeter, greeted)
    @greeter = greeter
    @greeted = greeted
  end
end

class MoneyTransferTest < Test::Unit::TestCase
  def test_greet
    p1 = Person.new
    p1.name = 'Bob'
    p1.greeting = 'Hello'

    p2 = Person.new
    p2.name = 'World!'
    p2.greeting = 'Greetings'

    #Execute is automagically created for the default interaction (specified by the second argument in context :Greet_Someone, :greet do)
    #Executes construct a context object and calls the default interaction on this object
    #Greet_Someone.assert_that(p1).can_play(:greeter)
    #constructs a Greet_Someone context object and executes greet.
    res = Greet_Someone.new(p2, p1).greet
  assert_equal("",res)
  end

end
