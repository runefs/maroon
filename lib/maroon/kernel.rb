require_relative '../Context'

unless Kernel::methods.detect { |m| m== :context }
  def context(*args, &b)
    Contetx.define *args, &b
  end
end