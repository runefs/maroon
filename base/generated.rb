class Greet_Someone
  def greet
    puts("\#{greeter.name}: \"#{greeter.welcome}, #{greeted.name}!\"") end
  def self.call(*args)
    arity = Greet_Someone.method(:new).arity
    newArgs = args[0..arity-1]
    obj = Greet_Someone.new *newArgs
    if arity < args.length
      methodArgs = args[arity..-1]
      obj.greet *methodArgs
    else
      obj.greet
    end
  end
  def call(*args);greet *args; end
  @greeter
  @greeted
  private
  def greeter;@greeter end
  def greeted;@greeted end
  def self_greeter_welcome
    greeter.greeting end
end