require_relative 'helper'
require_relative 'method_call.rb'

context :Expression, :transform do
  initialize do |expression, interpretation_context|
    raise "No expression supplied" unless expression
    @block, @block_body = nil
    if expression && expression[0] == :iter
      (expression.length-1).times do |i|
        expr = expression[i+1]
        #find the block
        if expr && expr.length && expr[0] == :block
          @block, @block_body = expr, expr[1]
        end
      end
    end
    @interpretation_context = interpretation_context
    @expression = expression
  end

  transform do
    if expression
      block.transform
      if expression[0] == :call
        MethodCall.new(expression,@interpretation_context).rewrite_call?
      end
      expression.each { |exp| Expression.new(exp, @interpretation_context)} if expression.instance_of? Sexp
    end
  end

  role :interpretation_context do end
  role :expression do  end
  role :block_body do  end
  role :block do
    ##
    #Transforms blocks as needed
    #-Rewrites self in role methods to the role getter
    #-Rewrites binds when needed
    #-Rewrites role method calls to instance method calls on the context
    ##
    transform do
      if block && block[0] == :iter
        (block.length-1).times do |i|
          expr = block[i+1]
          #find the block
          if expr && expr.length && expr[0] == :block
            Expression.rewrite(exp,@interpretation_context) if block.transform_bind?
          end
        end
      end
    end
    ##
    #Calls rewrite_block if needed and will return true if the AST was changed otherwise false
    ##
    transform_bind? do
      #check if the first call is a bind call
      if block_body && block_body.length && (block_body[0] == :call && block_body[1] == nil && block_body[2] == :bind)
        block.rewrite
      else
        false
      end
    end
    rewrite do
      changed = false
      argument_list = block_body[3]
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
            Bind.rewrite local, aliased_role, block
            changed = true
          end
        end
      end
      changed
    end
  end
end
