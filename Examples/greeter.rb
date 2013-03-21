#Thanks to Ted Milken for updating the original example
require_relative '../base/maroon_base.rb'
#require_relative '../base/maroon/kernel.rb'
#require_relative '../base/maroon/contracts.rb'

class Person
  attr_accessor :name
  attr_accessor :greeting
end

ctx, source = Context::define :Greet_Someone, :greet do
  role :greeter do
    welcome do
      self.greeting
    end
  end

  role :greeted do
  end

  greet do
    puts %{#{greeter.name}: "#{greeter.welcome}, #{greeted.name}!"}
  end
end

class Greet_Someone
  def initialize(greeter, greeted)
    @greeter = greeter
    @greeted = greeted
  end
end

p source
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
Greet_Someone.new(p2, p1).greet