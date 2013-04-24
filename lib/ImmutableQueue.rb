class ImmutableQueue

  def push(element)
    b = (back or ImmutableStack.empty)
    ImmutableQueue.new(front, b.push(element))

  end

  def pop()
    f, b = front, back
    if (f == ImmutableStack.empty) then
      until (b == ImmutableStack.empty) do
        (e, b = b.pop
        f = f.push(e))
      end
    end
    head, f = f.pop
    if (f == b) then
      [head, ImmutableQueue.empty]
    else
      [head, ImmutableQueue.new(f, b)]
    end

  end

  def self.empty()
    @@empty ||= ImmutableQueue.new(ImmutableStack.empty, ImmutableStack.empty)

  end

  def push_array(arr)
    q = self
    arr.each { |i| q = q.push(i) } if arr
    q

  end

  private

  def initialize(front, back)
    @front = (front or ImmutableStack.empty)
    @back = (back or ImmutableStack.empty)
    self.freeze

  end

  attr_reader :front
  attr_reader :back


end