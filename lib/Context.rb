class Context
  def self.define(*args, &block)
    @@with_contracts ||= nil
    @@generate_file_path ||= nil
    (alias :method_missing :role_or_interaction_method)
    ctx = self.send(:create_context_factory, args, block)
    return ctx.send(:finalize, @@generate_file_path, @@with_contracts)
  end

  def self.generate_files_in(*args, &b)
    if block_given? then
      return role_or_interaction_method(:generate_files_in, *args, &b)
    end
    @@generate_file_path = args[0]
  end

  def get_definitions(b)
    sexp = b.to_sexp
    unless is_definition?(sexp[3]) then
      sexp = sexp[3]
      sexp = sexp.select { |exp| is_definition?(exp) } if sexp
      sexp ||= []
    end
    sexp.select { |exp| is_definition?(exp) }
  end

  def self.create_context_factory(args, block)
    name, base_class, default_interaction = *args
    if default_interaction and (not base_class.instance_of?(Class)) then
      base_class = eval(base_class.to_s)
    end
    if base_class and ((not default_interaction) and (not base_class.instance_of?(Class))) then
      base_class, default_interaction = default_interaction, base_class
    end
    ctx = Context.new(name, base_class, default_interaction)
    ctx.instance_eval do
      sexp = block.to_sexp
      temp_block = sexp[3]
      i = 0
      while (i < temp_block.length) do
        exp = temp_block[i]
        unless temp_block[(i - 2)] and ((temp_block[(i - 2)][0] == :call) and (temp_block[(i - 1)] and (temp_block[(i - 1)][0] == :args))) then
          if ((exp[0] == :defn) or (exp[0] == :defs)) then
            add_method(exp)
            temp_block.delete_at(i)
            i = (i - 1)
          else
            if (exp[0] == :call) and ((exp[1] == nil) and (exp[2] == :private)) then
              @private = true
            end
          end
        end
        i = (i + 1)
      end
      ctx.instance_eval(&block)
    end
    ctx
  end

  def self.with_contracts(*args)
    return @@with_contracts if (args.length == 0)
    value = args[0]
    if @@with_contracts and (not value) then
      raise("make up your mind! disabling contracts during execution will result in undefined behavior")
    end
    @@with_contracts = value
  end

  def name_from_def(definition)
    if definition[1].instance_of?(Symbol) then
      definition[1]
    else
      ((definition[1].select { |e| e.instance_of?(Symbol) }.map { |e| e.to_s }.join(".") + ".") + definition[2].to_s).to_sym
    end
  end

  def create_info(definition)
    raise("Sexp require") unless definition.instance_of?(Sexp)
    name = name_from_def(definition)
    real_name = if @defining_role then
                  ((("self_" + @defining_role.to_s) + "_") + name.to_s)
                else
                  name
                end
    MethodInfo.new(definition, real_name, @private)
  end

  def is_definition?(exp)
    exp and ((exp[0] == :defn) or (exp[0] == :defs))
  end

  def role(*args, &b)
    role_name = args[0]
    if (args.length.!=(1) or (not role_name.instance_of?(Symbol))) then
      return role_or_interaction_method(:role, *args, &b)
    end
    @defining_role = role_name
    @roles = {} unless @roles
    @roles[role_name] = Hash.new
    definitions = get_definitions(b)
    definitions.each { |exp| add_method(exp) }
  end

  def current_interpretation_context(*args, &b)
    if block_given? then
      return role_or_interaction_method(:current_interpretation_context, *args, &b)
    end
    InterpretationContext.new(@roles, @contracts, @role_alias, nil)
  end

  def get_methods(*args, &b)
    return role_or_interaction_method(:get_methods, *args, &b) if block_given?
    name = args[0]
    sources = (@defining_role ? (@roles[@defining_role]) : (@interactions))[name]
    if @defining_role and (not sources) then
      @roles[@defining_role][name] = []
    else
      @interactions[name] = []
    end
  end

  def add_method(exp)
    name = name_from_def(exp)
    sources = get_methods(name)
    (sources << exp)
  end

  def finalize(file_path, with_contracts)
    raise("No name") unless @name
    code = generate_context_code
    if file_path then
      name = @name.to_s
      complete = ((((("class " + name) + (@base_class ? (("<< " + @base_class.name)) : (""))) + "\n      ") + code.to_s) + "\n           end")
      File.open((((("./" + file_path.to_s) + "/") + name) + ".rb"), "w") do |f|
        f.write(complete)
      end
      complete
    else
      c = @base_class ? (Class.new(base_class)) : (Class.new)
      if with_contracts then
        c.class_eval("def self.assert_that(obj)\n  ContextAsserter.new(self.contracts,obj)\nend\ndef self.refute_that(obj)\n  ContextAsserter.new(self.contracts,obj,false)\nend\ndef self.contracts\n  @@contracts\nend\ndef self.contracts=(value)\n  @@contracts = value\nend")
        c.contracts = contracts
      end
      Kernel.const_set(@name, c)
      begin
        temp = c.class_eval(code)
      rescue SyntaxError
        p(("error: " + code))
      end
      (temp or c)
    end
  end

  def generate_context_code()
    getters = ""
    impl = ""
    interactions = ""
    @interactions.each do |method_name, methods|
      methods.each do |method|
        @defining_role = nil
        info = create_info(method)
        code = (" " + info.build_as_context_method(current_interpretation_context))
        method.is_private ? ((getters << code)) : ((interactions << code))
      end
    end
    if @default_interaction then
      (interactions << (((((((("\n               def self.call(*args)\n             arity = " + name.to_s) + ".method(:new).arity\n             newArgs = args[0..arity-1]\n             obj = ") + name.to_s) + ".new *newArgs\n             if arity < args.length\n                 methodArgs = args[arity..-1]\n                 obj.") + default.to_s) + " *methodArgs\n             else\n                obj.") + default.to_s) + "\n                             end\n         end\n         "))
      (interactions << (("\n            def call(*args);" + default.to_s) + " *args; end\n"))
    end
    @roles.each do |role, methods|
      (getters << (("attr_reader :" + role.to_s) + "\n      "))
      methods.each do |method_name, method_sources|
        unless (method_sources.length < 2) then
          raise(("Duplicate definition of " + method_name.to_s))
        end
        unless (method_sources.length > 0) then
          raise(("No source for " + method_name.to_s))
        end
        method_source = method_sources[0]
        @defining_role = role
        info = create_info(method_source)
        definition = info.build_as_context_method(current_interpretation_context)
        (impl << ("   " + definition.to_s)) if definition
      end
    end
    private_string = (getters + impl).strip!.!=("") ? ("\n     private\n") : ("")
    impl = impl.strip!.!=("") ? ((("\n    " + impl) + "\n    ")) : ("\n    ")
    (((interactions + private_string) + getters) + impl)
  end

  def role_or_interaction_method(*arguments, &b)
    method_name, on_self = *arguments
    unless method_name.instance_of?(Symbol) then
      on_self = method_name
      method_name = :role_or_interaction_method
    end
    raise(("Method with out block " + method_name.to_s)) unless block_given?
  end

  def private()
    @private = true
  end

  def initialize(name, base_class, default_interaction)
    @roles = {}
    @interactions = {}
    @role_alias = {}
    @name = name
    @base_class = base_class
    @default_interaction = default_interaction
  end

  private
  attr_reader :name
  attr_reader :base_class
  attr_reader :default_interaction


end