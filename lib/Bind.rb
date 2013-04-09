class Bind


  def initialize (local, aliased_role, block)
    @local = local
    @aliased_role = aliased_role
    @block = block
  end

  def execute
    unless aliased_role.instance_of?(Symbol) then
      raise("aliased_role must be a Symbol")
    end
    raise("local must be a Symbol") unless local.instance_of?(Symbol)
    aliased_field = "@#{aliased_role}".to_sym
    assignment = Sexp.new
    assignment[0] = :iasgn
    assignment[1] = aliased_field
    load_arg = Sexp.new
    load_arg[0] = :lvar
    load_arg[1] = local
    assignment[2] = load_arg
    block.insert(1, assignment)
    temp_symbol = "temp____#{aliased_role}".to_sym
    assignment = Sexp.new
    assignment[0] = :lasgn
    assignment[1] = temp_symbol
    load_field = Sexp.new
    load_field[0] = :ivar
    load_field[1] = aliased_field
    assignment[2] = load_field
    block.insert(1, assignment)
    assignment = Sexp.new
    assignment[0] = :iasgn
    assignment[1] = aliased_field
    load_temp = Sexp.new
    load_temp[0] = :lvar
    load_temp[1] = temp_symbol
    assignment[2] = load_temp
    block[block.length] = assignment
  end

  def self.call(*args)
    arity = Bind.method(:new).arity
    newArgs = args[0..arity-1]
    obj = Bind.new *newArgs
    if arity < args.length
      methodArgs = args[arity..-1]
      obj.execute *methodArgs
    else
      obj.execute
    end
  end

  def call(*args)
    ; execute *args;
  end

  private
  attr_reader :block
  attr_reader :local
  attr_reader :aliased_role


end