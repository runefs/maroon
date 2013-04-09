class Context
  @@with_contracts = false
  @@generate_file_path = nil

  def self.define(*args, &block)
    (alias :method_missing :role_or_interaction_method)
    base_class, ctx, default_interaction, name = self.send(:create_context_factory, args, block)
    if (args.last.instance_of?(FalseClass) or args.last.instance_of?(TrueClass)) then
      ctx.generate_file = args.last
    end
    return ctx.send(:finalize, name, base_class, default_interaction)
  end

  def self.generate_files_in (folder)
    @@generate_file_path = folder
  end

  private
  attr_reader :roles
  attr_reader :interactions
  attr_reader :defining_role
  attr_reader :role_alias
  attr_reader :alias_list
  attr_reader :cached_roles_and_alias_list
  attr_reader :generate_file
  attr_reader :contracts


  def generate_files_in (*args, &b)
    if block_given? then
      return role_or_interaction_method(:generate_files_in, *args, &b)
    end
    @generate_file_path = args[0]
  end

  def self.with_contracts (*args)
    return @@with_contracts if (args.length == 0)
    value = args[0]
    if @@with_contracts and (not value) then
      raise("make up your mind! disabling contracts during execution will result in undefined behavior")
    end
    @@with_contracts = value
  end

  def generate_file (*args, &b)
    if block_given? then
      return role_or_interaction_method(:generate_file, *args, &b)
    end
    (@@generate_file_path || @generate_file_path)
  end

  def generated_files_folder (*args, &b)
    if block_given? then
      return role_or_interaction_method(:generated_files_folder, *args, &b)
    end
    (@generate_file_path or @@generate_file_path)
  end

  def private
    @private = true
  end

  def role (*args, &b)
    role_name = args[0]
    if ((not (args.length == 1)) or (not role_name.instance_of?(Symbol))) then
      return role_or_interaction_method(:role, *args, &b)
    end
    @defining_role = role_name
    @roles[role_name] = Array.new
    yield if block_given?
    @defining_role = nil
  end

  def initialize (*args, &b)
    if block_given? then
      raise "????" unless args
      role_or_interaction_method(:initialize, *args, &b)
    else
      @roles = Hash.new
      @interactions = Array.new
      @role_alias = Hash.new
      @contracts = Hash.new
    end
  end

  def get_method (*args, &b)
    return role_or_interaction_method(:get_methods, *args, &b) if block_given?

    sources = (@defining_role ? (@roles[@defining_role]) : (@interactions))
    if @defining_role && !sources
      sources = (@roles[@defining_role] = [])
    end
    sources
  end


  def add_method (*args, &b)
    return role_or_interaction_method(:add_methods, *args, &b) if block_given?
    method = args[0]
    sources = get_method
    (sources << method)
    sources
  end

  def finalize (*args, &b)
    return role_or_interaction_method(:finalize, *args, &b) if block_given?
    name, base_class, default = *args

    code = generate_context_code(default, name)
    if @@with_contracts then
      c.class_eval("def self.assert_that(obj)\n          ContextAsserter.new(self.contracts,obj)\n        end\n        def self.refute_that(obj)\n          ContextAsserter.new(self.contracts,obj,false)\n        end\n        def self.contracts\n          @@contracts\n        end\n        def self.contracts=(value)\n          raise 'Contracts must be supplied' unless value\n          @@contracts = value\n        end")
      c.contracts = @contracts
    end
    if generate_file then
      complete = "class #{name}
      \n#{code}
      \nend"
      File.open("./#{generated_files_folder}/#{name}.rb", "w") do |f|
        f.write(complete)
      end
      complete
    else
      c = base_class ? (Class.new(base_class)) : (Class.new)
      Kernel.const_set(name, c)
      temp = c.class_eval(code)
      (temp or c)
    end
  end

  def self.create_context_factory (args, block)
    name, base_class, default_interaction = *args
    if default_interaction and (not base_class.instance_of?(Class)) then
      base_class = eval(base_class.to_s)
    end
    if base_class and ((not default_interaction) and (not base_class.instance_of?(Class))) then
      base_class, default_interaction = default_interaction, base_class
    end
    ctx = Context.new
    ctx.instance_eval(&block)
    return [base_class, ctx, default_interaction, name]
  end

  def current_interpretation_context(*args, &b)
    return role_or_interaction_method(:current_interpretation_context, *args, &b) if block_given?

    InterpretationContext.new(roles, contracts, role_alias, nil)
  end

  def generate_context_code (*args, &b)
    return role_or_interaction_method(:generate_context_code, *args, &b) if block_given?
    default, name = args

    getters = ""
    impl = ""
    interactions = ""
    @interactions.each do |method|
        method_name = method.name
        @defining_role = nil
        code = "  #{method.build_as_context_method(method_name, current_interpretation_context) }"
        if method.is_private
          getters << code
        else
          interactions << code
        end
    end
    if default then
      (interactions << "\n         def self.call(*args)\n             arity = #{name}.method(:new).arity\n             newArgs = args[0..arity-1]\n             obj = #{name}.new *newArgs\n             if arity < args.length\n                 methodArgs = args[arity..-1]\n                 obj.#{default} *methodArgs\n             else\n                obj.#{default}\n             end\n         end\n         ")
      (interactions << "\ndef call(*args);#{default} *args; end\n")
    end
    @roles.each do |role, methods|
      (getters << "attr_reader :#{role}\n")
      methods.each do |method_source|
        raise "Unexpected type (#{method_source.class.name}). Expected MethodInfo" unless method_source.instance_of? MethodInfo

        @defining_role = role
        rewritten_method_name = "self_#{role}_#{method_source.name}"
        definition = method_source.build_as_context_method rewritten_method_name, current_interpretation_context
        (impl << "  #{definition}") if definition
      end
    end
    "#{interactions}\n private\n#{getters}\n\#Start of role methods\n#{impl}\n"
  end

  def to_sexp &b
    b.to_sexp
  end
  def role_or_interaction_method (*args, &b)
    method_name, on_self = *args

    unless method_name.instance_of?(Symbol) then
      on_self = method_name
      method_name = :role_or_interaction_method
    end
    raise("method with out block #{method_name}") unless block_given?
    temp = @roles[:block_source] ? (@roles[:block_source].detect {|e| e.name == :get_arguments}) : nil
    temp = temp.send(:block_source) if temp
    source = to_sexp &b
    info = MethodInfo.new(method_name,on_self, source, @private).freeze
    add_method(info)
  end

  def copy_sexp(arr)
    res = Sexp.new
    arr.each do |e|
      if e.instance_of? Sexp
        res[res.length] = copy_sexp e
      else
        res[res.length] = e
      end
    end
    res
  end

  def self.assert_that(obj)
    ContextAsserter.new(self.contracts, obj)
  end

  def self.refute_that(obj)
    ContextAsserter.new(self.contracts, obj, false)
  end

  def self.contracts
    @@contracts
  end

  def self.contracts=(value)
    raise 'Contracts must be supplied' unless value
    @@contracts = value
  end

end