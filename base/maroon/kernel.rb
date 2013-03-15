module Kernel
  def context(*args, &b)
    Context::define *args, &b
  end
end