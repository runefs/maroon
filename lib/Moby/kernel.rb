module Kernel
  def context(name, &b)
    Context::define name, &b
  end
end