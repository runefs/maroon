c = context :ImmutableQueue do
  role :front do
  end
  role :back do
  end

  def push(element)
    b = back || ImmutableStack::empty
    ImmutableQueue.new(front, b.push(element))
  end

  def pop
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

  def self.empty
    @empty ||= ImmutableQueue.new(ImmutableStack::empty, ImmutableStack::empty)
  end

  def push_array(arr)
    q = self
    if arr
      arr.each do |i|
        q = q.push i
      end
    end
    q
  end

  private

  def initialize(front, back)
    @front = front || ImmutableStack::empty
    @back = back || ImmutableStack::empty
    self.freeze
  end

end

# context_class_code = c.generated_class
# 
# if context_class_code.instance_of? String
#   file_name = './generated/immutable_queue.rb'
#   p "writing to: " + file_name
#   File.open(file_name, 'w') do |f|
#     f.write(context_class_code)
#   end
# end
