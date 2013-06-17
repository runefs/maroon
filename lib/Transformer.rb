class Transformer
  def initialize(context_name, roles, interactions, private_interactions, base_class, default_interaction)
    @context_name = context_name
    @roles = roles
    p context_name
    p "roles: " + roles.to_s
    @interactions = interactions
    p "interactions: " + interactions.to_s
    @base_class = base_class
    @default_interaction = default_interaction
    @private_interactions = private_interactions
    @definitions = {}
  end

  def transform(file_path, with_contracts)
    code = (self_interactions_generated_source + self_roles_generated_source)
    if file_path then
      name = context_name.to_s
      complete = ((((("class " + name) + (@base_class ? (("<< " + @base_class.name)) : (""))) + "\n      ") + code.to_s) + "\n           end")
      File.open((((("./" + file_path.to_s) + "/") + name) + ".rb"), "w") do |f|
        f.write(complete)
      end
      complete
    else
      c = @base_class ? (Class.new(base_class)) : (Class.new)
      if with_contracts then
        c.class_eval("def self.assert_that(obj)\n  ContextAsserter.new(self.contracts,obj)\nend\ndef self.refute_that(obj)\n  ContextAsserter.new(self.contracts,obj,false)\nend\ndef self.contracts\n  @contracts\nend\ndef self.contracts=(value)\n  @contracts = value\nend")
        c.contracts = contracts
      end
      Kernel.const_set(context_name, c)
      begin
        temp = c.class_eval(code)
      rescue SyntaxError
        p(("error: " + code))
      end
      (temp or c)
    end
  end

  private
  def contracts()
    @contracts ||= {}
  end

  def role_aliases()
    @role_aliases ||= {}
  end

  def interpretation_context()
    InterpretationContext.new(roles, contracts, role_aliases, defining_role, @private_interactions)
  end

  def self_roles_generated_source()
    impl = ""
    getters = []
    roles.each do |role, methods|
      (getters << role.to_s)
      methods.each do |name, method_sources|
        temp____defining_role = @defining_role
        @defining_role = role
        temp____method_name = @method_name
        @method_name = name
        temp____method = @method
        @method = method_sources
        definition = self_method_generated_source
        (impl << ("   " + definition)) if definition
        @method = temp____method
        @method_name = temp____method_name
        @defining_role = temp____defining_role
      end
    end
    ((((impl.strip! or "") + "\n") + ((getters.length > 0) ? (("attr_reader :" + getters.join(", :"))) : (""))) + "\n")
  end

  def self_interactions_generated_source()
    internal_methods = ""
    external_methods = self_interactions_default
    interactions.each do |name, interact|
      interact.each do |m|
        temp____method_name = @method_name
        @method_name = name
        temp____method = @method
        @method = m
        @defining_role = nil
        code = self_method_generated_source
        (((self_method_is_private? ? (internal_methods) : (external_methods)) << " ") << code)
        @method = temp____method
        @method_name = temp____method_name
      end
    end
    ((((external_methods.strip! or "") + "\n     private\n") + (internal_methods.strip! or "")) + "\n")
  end

  def self_interactions_default()
    if @default then
      (((((((((("\n               def self.call(*args)\n             arity = " + name.to_s) + ".method(:new).arity\n             newArgs = args[0..arity-1]\n             obj = ") + name.to_s) + ".new *newArgs\n             if arity < args.length\n                 methodArgs = args[arity..-1]\n                 obj.") + default.to_s) + " *methodArgs\n             else\n                obj.") + default.to_s) + "\n                             end\n         end\n            def call(*args);") + default.to_s) + " *args; end\n")
    else
      ""
    end
  end

  def self_method_is_private?()
    (defining_role.!=(nil) or private_interactions.has_key?(self_method_name))
  end

  def self_method_definition()
    key = ((@defining_role ? (@defining_role.to_s) : ("")) + method_name.to_s)
    return @definitions[key] if @definitions.has_key?(key)
    unless method.instance_of?(Sexp) then
      unless method.instance_of?(Array) and (method.length < 2) then
        raise((((("Duplicate definition of " + method_name.to_s) + "(") + method.to_s) + ")"))
      end
      unless method.instance_of?(Array) and (method.length > 0) then
        raise(("No source for " + method_name.to_s))
      end
    end
    d = method.instance_of?(Array) ? (method[0]) : (method)
    raise("Sexp require") unless d.instance_of?(Sexp)
    @definitions[key] = d
  end

  def self_method_body()
    args = self_method_definition.detect { |d| (d[0] == :args) }
    index = (self_method_definition.index(args) + 1)
    if (self_method_definition.length > (index + 1)) then
      body = self_method_definition[(index..-1)]
      body.insert(0, :block)
      body
    else
      self_method_definition[index]
    end
  end

  def self_method_arguments()
    args = self_method_definition.detect { |d| (d[0] == :args) }
    args and (args.length > 1) ? (args[(1..-1)]) : ([])
  end

  def self_method_name()
    name = if self_method_definition[1].instance_of?(Symbol) then
             self_method_definition[1].to_s
           else
             ((self_method_definition[1].select { |e| e.instance_of?(Symbol) }.map do |e|
               e.to_s
             end.join(".") + ".") + self_method_definition[2].to_s)
           end
    (
    if defining_role then
      ((("self_" + @defining_role.to_s) + "_") + name.to_s)
    else
      name
    end).to_sym
  end

  def self_method_generated_source()
    AstRewritter.new(self_method_body, interpretation_context).rewrite!
    body = Ruby2Ruby.new.process(self_method_body)
    raise("Body is undefined") unless body
    args = self_method_arguments
    if args and args.length then
      args = (("(" + args.join(",")) + ")")
    else
      args = ""
    end
    header = (("def " + self_method_name.to_s) + args)
    (((header + " ") + body) + " end\n")
  end

  attr_reader :private_interactions, :context_name, :roles, :interactions, :method_name, :defining_role, :method

end