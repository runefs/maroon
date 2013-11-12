c = context :ImmutableStack do
  role :head do
  end
  role :tail do
  end

  def pop
    [@head, @tail]
  end

  def push(element)
    ImmutableStack.new element, self
  end

  def self.empty
    @empty ||= self.new(nil, nil)
  end

  def each
    yield head
    t = tail
    while t != ImmutableStack::empty do
      h, t = t.pop
      yield h
    end
  end

  def initialize(h, t)
    @head = h
    @tail = t
    self.freeze
  end
end

context_class_code = c.generated_class

if context_class_code.instance_of? String
  file_name = './generated/immutable_stack.rb'
  p "writing to: " + file_name
  File.open(file_name, 'w') do |f|
    f.write(context_class_code)
  end
end
