require 'ripper'

module Rewriter
  private
  def role_aliases
    @alias_list if @alias_list
    @alias_list = Hash.new
    @role_alias.each { |aliases|
      aliases.each { |k, v|
        @alias_list[k] = v
      }
    }
    @alias_list
  end

  def roles
    @cached_roles_and_alias_list if @cached_roles_and_alias_list
    @roles unless @role_alias and @role_alias.length
    @cached_roles_and_alias_list = Hash.new
    @roles.each { |k, v|
      @cached_roles_and_alias_list[k] = v
    }
    role_aliases.each { |k, v|
      @cached_roles_and_alias_list[k] = @roles[v]
    }
    @cached_roles_and_alias_list
  end

  def add_alias (a, role_name)
    @cached_roles_and_alias_list, @alias_list = nil
    @role_alias.last()[a] = role_name
  end

  def role_method_call(ast, method)
    is_call_expression = ast && ast[0] == :call
    self_is_instance_expression = is_call_expression && (!ast[1]) #implicit self
    is_in_block = ast && ast[0] == :lvar
    role_name_index = self_is_instance_expression ? 2 : 1
    role = (self_is_instance_expression || is_in_block) ? roles[ast[role_name_index]] : nil #is it a call to a role getter
    is_role_method = role && role.has_key?(method)
    role_name = is_in_block ? role_aliases[ast[1]] : (ast[2] if self_is_instance_expression)
    role_name if is_role_method #return role name
  end

##
#Transforms blocks as needed
#-Rewrites self in role methods to the role getter
#-Rewrites binds when needed
#-Rewrites role method calls to instance method calls on the context
##
  def transform_block(exp)
    if exp && exp[0] == :iter
      (exp.length-1).times do |i|
        expr = exp[i+1]
        #find the block
        if expr && expr.length && expr[0] == :block
          transform_ast exp if rewrite_bind? expr, expr[1]
        end
      end
    end
  end

##
#Calls rewrite_block if needed and will return true if the AST was changed otherwise false
##
  def rewrite_bind?(block, expr)
    #check if the first call is a bind call
    if expr && expr.length && (expr[0] == :call && expr[1] == nil && expr[2] == :bind)
      rewrite_bind_in_block(block, expr)
    else
      false
    end
  end

  def rewrite_bind_in_block(block, expr)
    changed = false
    argument_list = expr[3]
    if argument_list && argument_list[0] == :arglist
      arguments = argument_list[1]
      if arguments && arguments[0] == :hash
        block.delete_at 1
        count = (arguments.length-1) / 2
        (1..count).each do |j|
          temp = j * 2
          local = arguments[temp-1][1]
          if local.instance_of? Sexp
            local = local[1]
          end
          raise 'invalid value for role alias' unless local.instance_of? Symbol
          #find the name of the role being bound to
          aliased_role = arguments[temp][1]
          if aliased_role.instance_of? Sexp
            aliased_role = aliased_role[1]
          end
          raise "#{aliased_role} used in binding is an unknown role #{roles}" unless aliased_role.instance_of? Symbol and @roles.has_key? aliased_role
          add_alias local, aliased_role
          #replace bind call with assignment of iteration variable to role field
          rewrite_bind_ast(aliased_role, local, block)
          changed = true
        end
      end
    end
    changed
  end

##
#removes call to bind in a block
#and replaces it with assignment to the proper role player local variables
#in the end of the block the local variables have their original values reassigned
  def rewrite_bind_ast(aliased_role, local, block)
    raise 'aliased_role must be a Symbol' unless aliased_role.instance_of? Symbol
    raise 'local must be a Symbol' unless local.instance_of? Symbol
    # assigning role player to role filed
    #notice that this will be executed after the next block
    aliased_field = "@#{aliased_role}".to_sym
    assignment = Sexp.new
    assignment[0] = :iasgn
    assignment[1] = aliased_field
    load_arg = Sexp.new
    load_arg[0] = :lvar
    load_arg[1] = local
    assignment[2] = load_arg
    block.insert 1, assignment

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

# rewrites a call to self in a role method to a call to the role player accessor
# which is subsequently rewritten to a call to the instance variable itself
# in the case where no role method is called on the role player
# It's rewritten to an instance call on the context object if a role method is called
  def rewrite_self (ast)
    ast.length.times do |i|
      raise 'Invalid argument. must be an expression' unless ast.instance_of? Sexp
      exp = ast[i]
      if exp == :self
        ast[0] = :call
        ast[1] = nil
        ast[2] = @defining_role
        arglist = Sexp.new
        ast[3] = arglist
        arglist[0] = :arglist
      elsif exp.instance_of? Sexp
        rewrite_self exp
      end
    end
  end

#rewrites the ast so that role method calls are rewritten to a method invocation on the context object rather than the role player
#also does rewriting of binds in blocks
  def transform_ast(ast)
    if ast
      if @defining_role
        rewrite_self ast
      end
      ast.length.times do |k|
        exp = ast[k]
        if exp
          method_name = exp[2]
          role = role_method_call exp[1], exp[2]
          if exp[0] == :iter
            @role_alias.push Hash.new
            transform_block exp
            @role_alias.pop()
          end
          if exp[0] == :call && role
            exp[1] = nil #remove call to attribute
            exp[2] = "self_#{role}_#{method_name}".to_sym
          end
          if exp.instance_of? Sexp
            transform_ast exp
          end
        end
      end
    end
  end
end
