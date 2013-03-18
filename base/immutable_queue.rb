context :ImmutableQueue do
  role :front do end
  role :back do end
  push do |element|
    b = back || ImmutableStack::empty 
    ImmutableQueue.new(front, b.push(element))
  end

  pop do
    f,b = front,back
    if f == ImmutableStack::empty
      until b == ImmutableStack::empty do
        e,b = b.pop()
        f = f.push(e)
      end
    end
    head,f = f.pop
    if f == b #can only happen if they are both ImmutableStack::empty
      [head,ImmutableQueue::empty]
    else
      [head, ImmutableQueue.new(f,b)]
    end
  end

  initialize do |front,back|
    unless self.class.method_defined? :empty
      self.class.class_eval do
        ImmutableStack.new nil,nil unless ImmutableStack.method_defined? :empty
        def self.empty
          @@empty ||= ImmutableQueue.new(ImmutableStack::empty,ImmutableStack::empty)
        end
      end
    end

    @front = front  || ImmutableStack::empty
    @back = back || ImmutableStack::empty
    self.freeze
  end
  push_array do |arr|
    q = self
    if arr
      arr.each do |i|
       q = q.push i
     end
    end
    q
  end
  each do
    head,queue = self.pop
    yield head
    while queue != ImmutableQueue::empty do
      h,queue = queue.pop
      yield h
    end
  end
end