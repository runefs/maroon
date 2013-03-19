require_relative 'helper'
context :ImmutableStack do
   role :head do end
   role :tail do end
   pop do
     [head,tail]
   end
   push do |element|
     ImmutableStack.new element, self
   end

   initialize do |h,t|
     @head = h
     @tail = t
     self.freeze
   end

   empty self do
     @@empty ||= self.new(nil,nil)
   end

   each do
     yield head
     t = tail
     while t != ImmutableStack::empty do
       h,t = t.pop
       yield h
     end
   end
end

