require '../lib/Moby.rb'
require '../lib/Moby/kernel.rb'

class Foo
  def say
    self.greet
  end
end

p (Context::define :Greeter, Foo do
  role :who do
    say do
      self
    end
    talk do
      self.say
    end
  end
  role :greeting do end
  greet do
    p "#{greeting} #{who.say}!"
  end
end)

class Greeter
  def initialize(greeting,player)
    @who = player
    @greeting = greeting
  end
end

Greeter.new('hello','world').greet #Will print "Hello world!"
Greeter.new('hello','world').say #calls greet and provides that inheritance works