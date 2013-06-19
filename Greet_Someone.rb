class Greet_Someone
         def greet() (((((greeter.name.to_s + ": ") + greeter.welcome.to_s) + " ") + greeted.name.to_s) + "!") end
   def initialize(greeter,greeted) @greeter = greeter
@greeted = greeted
 end
   def self_greeter_welcome() greeter.greeting end

           attr_reader :greeter, :greeted
           end