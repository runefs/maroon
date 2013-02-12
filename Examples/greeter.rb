require '../lib/Moby.rb'
require '../lib/Moby/kernel.rb'

context :Greeter do
  role :who do
    say do
      self
    end
    talk do
      self.say
    end
  end
  greeting do
    p "Hello #{who.talk}!"
  end
end

class Greeter
  def initialize(player)
    @who = player
  end
end

Greeter.new('world').greeting #Will print "Hello world!"