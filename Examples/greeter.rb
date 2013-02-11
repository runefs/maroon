require '../lib/Moby.rb'

Context::define :Greeter do
  role :who do
    say do
      @who
    end
  end
  greeting do
    p "Hello #{who.say}!"
  end
end

class Greeter
  def initialize(player)
    @who = player
  end
end

Greeter.new('world').greeting #Will print "Hello world!"