require_relative 'helper'

context :Bind, :execute do
  role :block do
  end
  role :local do
  end
  role :aliased_role do
  end
  initialize do |local, aliased_role, block|
    @local = local
    @aliased_role = aliased_role
    @block = block
  end
  ##
  #removes call to bind in a block
  #and replaces it with assignment to the proper role player local variables
  #in the end of the block the local variables have their original values reassigned
  execute do
    raise 'aliased_role must be a Symbol' unless aliased_role.instance_of? Symbol
    raise 'local must be a Symbol' unless local.instance_of? Symbol
    # assigning role player to role field
    #notice that this will be executed after the next block
    aliased_field = "@#{aliased_role}".to_sym
    assignment = Sexp.new
    assignment[0] = :iasgn
    assignment[1] = aliased_field
    load_arg = Sexp.new
    load_arg[0] = :lvar
    load_arg[1] = local
    assignment[2] = load_arg
    block[1] = assignment

    # assign role player to temp
    # notice this is prepended Ie. inserted in front of the role player to role field
    temp_symbol = "temp____#{aliased_role}".to_sym
    assignment = Sexp.new
    assignment[0] = :lasgn
    assignment[1] = temp_symbol
    load_field = Sexp.new
    load_field[0] = :ivar
    load_field[1] = aliased_field
    assignment[2] = load_field
    block.insert 1, assignment

    # reassign original player
    assignment = Sexp.new
    assignment[0] = :iasgn
    assignment[1] = aliased_field
    load_temp = Sexp.new
    load_temp[0] = :lvar
    load_temp[1] = temp_symbol
    assignment[2] = load_temp
    block[block.length] = assignment
  end
end