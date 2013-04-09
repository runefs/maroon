class Context
       
def self.define(*args,&block)
    @@with_contracts ||= nil
@@generate_file_path ||= nil
(alias :method_missing :role_or_interaction_method)
base_class, ctx, default_interaction, name = self.send(:create_context_factory, args, block)
if (args.last.instance_of?(FalseClass) or args.last.instance_of?(TrueClass)) then
  ctx.generate_files_in(args.last)
end
return ctx.send(:finalize, name, base_class, default_interaction)

 end
 
def self.generate_files_in(*args,&b)
    if block_given? then
  return role_or_interaction_method(:generate_files_in, *args, &b)
end
@@generate_file_path = args[0]

 end

 private
 
def self.with_contracts(*args)
    return @@with_contracts if (args.length == 0)
value = args[0]
if @@with_contracts and (not value) then
  raise("make up your mind! disabling contracts during execution will result in undefined behavior")
end
@@with_contracts = value

 end
 
def role(*args,&b)
    role_name = args[0]
if (args.length.!=(1) or (not role_name.instance_of?(Symbol))) then
  return role_or_interaction_method(:role, *args, &b)
end
@defining_role = role_name
@roles[role_name] = Hash.new
yield if block_given?
@defining_role = nil

 end
 
def initialize(*args,&b)
    if block_given? then
  role_or_interaction_method(:initialize, *args, &b)
else
  @roles = Hash.new
  @interactions = Hash.new
  @role_alias = Hash.new
  @contracts = Hash.new
end
 end
 
def private()
    @private = true
 end
 
def current_interpretation_context(*args,&b)
    if block_given? then
  return role_or_interaction_method(:current_interpretation_context, *args, &b)
end
InterpretationContext.new(roles, contracts, role_alias, nil)

 end
 
def get_methods(*args,&b)
    return role_or_interaction_method(:get_methods, *args, &b) if block_given?
name = args[0]
sources = (@defining_role ? (@roles[@defining_role]) : (@interactions))[name]
if @defining_role and (not sources) then
  @roles[@defining_role][name] = []
else
  @interactions[name] = []
end

 end
 
def add_method(*args,&b)
    return role_or_interaction_method(:add_method, *args, &b) if block_given?
name, method = *args
sources = get_methods(name)
(sources << method)

 end
 
def finalize(*args,&b)
    return role_or_interaction_method(:finalize, *args, &b) if block_given?
name, base_class, default = *args
code = generate_context_code(default, name)
if @@generate_file_path then
  name = name.to_s
  complete = ((((("class " + name) + (base_class ? (("<< " + base_class.name)) : (""))) + "\n      ") + code.to_s) + "\n      end")
  File.open((((("./" + @@generate_file_path.to_s) + "/") + name) + ".rb"), "w") do |f|
    f.write(complete)
  end
  complete
else
  c = base_class ? (Class.new(base_class)) : (Class.new)
  if @@with_contracts then
    c.class_eval("def self.assert_that(obj)\n          ContextAsserter.new(self.contracts,obj)\n        end\n        def self.refute_that(obj)\n          ContextAsserter.new(self.contracts,obj,false)\n        end\n        def self.contracts\n          @@contracts\n        end\n        def self.contracts=(value)\n          raise 'Contracts must be supplied' unless value\n          @@contracts = value\n        end")
    c.contracts = contracts
  end
  Kernel.const_set(name, c)
  temp = c.class_eval(code)
  (temp or c)
end

 end
 
def self.create_context_factory(args,block)
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
 
def generate_context_code(*args,&b)
    if block_given? then
  return role_or_interaction_method(:generate_context_code, *args, &b)
end
default, name = args
getters = ""
impl = ""
interactions = ""
@interactions.each do |method_name, methods|
  methods.each do |method|
    @defining_role = nil
    code = (" " + method.build_as_context_method(method_name, current_interpretation_context))
    method.is_private ? ((getters << code)) : ((interactions << code))
  end
end
if default then
  (interactions << (((((((("\n         def self.call(*args)\n             arity = " + name.to_s) + ".method(:new).arity\n             newArgs = args[0..arity-1]\n             obj = ") + name.to_s) + ".new *newArgs\n             if arity < args.length\n                 methodArgs = args[arity..-1]\n                 obj.") + default.to_s) + " *methodArgs\n             else\n                obj.") + default.to_s) + "\n             end\n         end\n         "))
  (interactions << (("\n      def call(*args);" + default.to_s) + " *args; end\n"))
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
    rewritten_method_name = ((("self_" + role.to_s) + "_") + method_name.to_s)
    definition = method_source.build_as_context_method(rewritten_method_name, current_interpretation_context)
    (impl << ("   " + definition.to_s)) if definition
  end
end
(((((interactions + "\n private\n") + getters) + "\n    ") + impl) + "\n    ")

 end
 
def role_or_interaction_method(*arguments,&b)
    method_name, on_self = *arguments
unless method_name.instance_of?(Symbol) then
  on_self = method_name
  method_name = :role_or_interaction_method
end
raise(("Method with out block " + method_name.to_s)) unless block_given?
add_method(method_name, MethodInfo.new(on_self, b.to_sexp, @private))

 end
attr_reader :roles
      attr_reader :interactions
      attr_reader :defining_role
      attr_reader :role_alias
      attr_reader :alias_list
      attr_reader :cached_roles_and_alias_list
      attr_reader :contracts
      
    
    
      end