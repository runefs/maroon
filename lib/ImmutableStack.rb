class ImmutableStack
  def pop()
    [@head, @tail]
  end

  def push(element)
    ImmutableStack.new(element, self)
  end

  def self.empty()
    @empty ||= self.new(nil, nil)
  end

  def each()
    yield(head)
    t = tail
    while t.!=(ImmutableStack.empty) do
      h, t = t.pop
      yield(h)
    end
  end

  def initialize(h, t)
    @head = h
    @tail = t
    self.freeze
  end

  private


  attr_reader :head
  attr_reader :tail

end