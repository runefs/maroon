context :MethodDefinition, :transform do

  rebind do
    @exp, @expressions = expressions.pop
    @block, @potential_bind = nil
    if @exp && (@exp.instance_of? Sexp) && @exp[0] == :iter
      @exp[1..-1].each do |expr|
        #find the block
        if expr && expr.length && expr[0] == :block
          @block, @potential_bind = expr, expr[1]
        end
      end
    end
    @expressions = if @exp.instance_of? Sexp then
                     @expressions.push_array(exp)
                   else
                     @expressions
                   end
  end

  transform do
    #could have been recursive but the stack depth isn't enough for even simple contexts
    until expressions.empty?

      block.transform
      if exp && (exp.instance_of? Sexp)
        is_indexer = exp[0] == :call && exp[1] == nil && (exp[2] == :[] || exp[2] == :[]=)
        if  (is_indexer || (exp[0] == :self)) && @interpretation_context.defining_role
          Self.new(exp, interpretation_context).execute
        end
        if exp[0] == :call
          MethodCall.new(exp, interpretation_context).rewrite_call?
        end
      end
      rebind
    end
  end

  initialize do |exp, interpretationcontext|
    no_exp = 'No expression supplied'.to_sym
    no_ctx = 'No interpretation context'.to_sym

    raise no_exp unless exp
    raise no_ctx unless interpretationcontext

    @interpretation_context = interpretationcontext
    @expressions = ImmutableQueue::empty.push exp
    rebind
  end

  role :interpretation_context do
    addalias do |key, value|
      self.role_aliases[key] = value
    end
  end
  role :exp do
  end
  role :expressions do
    empty? do
      expressions == ImmutableQueue::empty
    end
  end
  role :potential_bind do
    is_bind? do
      potential_bind &&
          potential_bind.length &&
          (potential_bind[0] == :call &&
              potential_bind[1] == nil &&
              potential_bind[2] == :bind)
    end
  end
  role :block do
    ##
    #Transforms blocks as needed
    #-Rewrites self in role methods to the role getter
    #-Rewrites binds when needed
    #-Rewrites role method calls to instance method calls on the context
    ##
    transform do
      if block
        if block.transform_bind?
          @expressions.push_array(block[1..-1])
        end
      end
    end
    ##
    #Calls rewrite_block if needed and will return true if the AST was changed otherwise false
    ##
    transform_bind? do
      #check if the first call is a bind call
      potential_bind.is_bind? && block.rewrite
    end

    rewrite do
      changed = false
      argument_list = potential_bind[3]
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
            raise aliased_role.to_s + 'used in binding is an unknown role ' + roles.to_s unless aliased_role.instance_of? Symbol and interpretation_context.roles.has_key? aliased_role
            interpretation_context.addalias local, aliased_role
            #replace bind call with assignment of iteration variable to role field
            Bind.new(local, aliased_role, block).execute
            changed = true
          end
        end
      end
      changed
    end
  end

end