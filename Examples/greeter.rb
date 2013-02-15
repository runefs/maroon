#Thanks to Ted Milken for updating the original example

require '../lib/Moby.rb'
require '../lib/Moby/kernel.rb'

class Person
  attr_accessor :name
  attr_accessor :greeting
end

context :Greet_Someone, :greet do
  role :greeter do
    welcome do
      self.greeting
    end
  end

  role :greeted do
  end

  greet do
    puts "#{greeter.name}: \"#{greeter.welcome}, #{greeted.name}!\""
  end
end

class Greet_Someone
  def initialize(greeter, greeted)
    @greeter = greeter
    @greeted = greeted
  end
end

p1 = Person.new
p1.name = 'Bob'
p1.greeting = 'Hello'

p2 = Person.new
p2.name = 'World!'
p2.greeting = 'Greetings'

Greet_Someone.execute p1, p2
Greet_Someone.new(p2, p1).greet