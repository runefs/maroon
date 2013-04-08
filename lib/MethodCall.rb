class MethodCall


  def rewrite_call?
    method_name = method[2]
    if (method[0] == :call) then
      if method[1] == nil && method.length < 5 && method[3] &&method[3][0] == :arglist && method[3].length == 1 then
        is_role = interpretation_context.roles.has_key?(method[3])
        method[3] = ":@#{method[3]}" if is_role
      else
        role_name, is_role_method = self_method_role_method_call?(method_name)
        if is_role_method then
          method[1] = nil
          method[2] = "self_#{role_name}_#{method_name}".to_sym
        else
          if interpretation_context.roles.has_key?(role_name) then
            contract_methods = interpretation_context.contracts[role_name] ||= {}
            contract_methods[method_name] ||= 0
            contract_methods[method_name] += 1
          end
        end
      end
    else
      p("method[0] was #{method[0]}")
    end
  end

  def initialize (method, interpretation_context)
    raise("No method supplied") unless method and method.length
    @method = method
    @interpretation_context = interpretation_context
  end

  def self.call(*args)
    arity = MethodCall.method(:new).arity
    newArgs = args[0..arity-1]
    obj = MethodCall.new *newArgs
    if arity < args.length
      methodArgs = args[arity..-1]
      obj.rewrite_call? *methodArgs
    else
      obj.rewrite_call?
    end
  end

  def call(*args)
    ; rewrite_call? *args;
  end

  private
  attr_reader :interpretation_context
  attr_reader :method


  def self_method_call_in_block?
    @in_block unless (@in_block == nil)
    @in_block = (method and (method[0] == :lvar))
  end

  def self_method_get_role_definition
    is_call_expression = (method and (method[0] == :call))
    self_is_instance_expression = (is_call_expression and (not method[1]))
    role_name = nil
    role_name = method[2] if self_is_instance_expression
    if (not self_is_instance_expression) and method[1] then
      if (method[1][1] == nil) and (method[1][0] == :call) then
        role_name = method[1][2]
      end
      if (method[1][0] == :lvar) then
        role_name = interpretation_context.role_aliases[method[1][1]]
      end
    end
    role = role_name ? (interpretation_context.roles[role_name]) : (nil)
    [role, role ? (role_name) : (nil)]
  end

  def self_method_role_method_call? (method_name)
    return [nil, nil] unless method
    role, role_name = self_method_get_role_definition
    is_role_method = (role and role.has_key?(method_name))
    return [role_name, is_role_method]
  end


end