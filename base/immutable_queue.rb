context :ImmutableQueue do
  role :front do
  end
  role :back do
  end
  push do |element|
    b = back || ImmutableStack::empty
    ImmutableQueue.new(front, b.push(element))
  end

  pop do
    f, b = front, back
    if f == ImmutableStack::empty
      #reverse the back stack to be able to pop from the front in correct order
      until b == ImmutableStack::empty
        e, b = b.pop
        f = f.push(e)
      end
    end
    head, f = f.pop
    if f == b #can only happen if they are both ImmutableStack::empty
      [head, ImmutableQueue::empty]
    else
      [head, ImmutableQueue.new(f, b)]
    end
  end

  empty true do
    @@empty ||= ImmutableQueue.new(ImmutableStack::empty, ImmutableStack::empty)
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

  private

  initialize do |front, back|
    @front = front || ImmutableStack::empty
    @back = back || ImmutableStack::empty
    self.freeze
  end

end