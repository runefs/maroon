class Transformer
         def initialize(context_name,definitions,private_interactions,base_class,default_interaction) raise("No method definitions to transform") if (definitions.length == 0)
@context_name = context_name
@definitions = definitions
@base_class = base_class
@default_interaction = default_interaction
@private_interactions = private_interactions
 end
   def transform(file_path,with_contracts) c = file_path ? (nil) : (@base_class ? (Class.new(base_class)) : (Class.new))
code = self_definitions_generate(c)
if file_path then
  name = context_name.to_s
  complete = ((((("class " + name) + (@base_class ? (("<< " + @base_class.name)) : (""))) + "\n      ") + code.to_s) + "\n           end")
  File.open((((("./" + file_path.to_s) + "/") + name) + ".rb"), "w") do |f|
    f.write(complete)
  end
  complete
else
  if with_contracts then
    c.class_eval("def self.assert_that(obj)\n  ContextAsserter.new(self.contracts,obj)\nend\ndef self.refute_that(obj)\n  ContextAsserter.new(self.contracts,obj,false)\nend\ndef self.contracts\n  @contracts\nend\ndef self.contracts=(value)\n  @contracts = value\nend")
    c.contracts = contracts
  end
  Kernel.const_set(context_name, c)
  temp = c.class_eval(code) rescue raise(code.to_sym)
  (temp or c)
end
 end
   def contracts() @contracts end
   def role_aliases() @role_aliases end
   def interpretation_context() InterpretationContext.new(definitions, contracts, role_aliases, defining_role, @private_interactions) end
   def self_method_is_private?() (defining_role.!=(nil) or private_interactions.has_key?(self_method_name)) end
   def self_method_is_interaction?() ((defining_role == nil) or (defining_role.name == nil)) end
   def self_method_definition() method end
   def self_method_body() args = self_method_definition.detect { |d| (d[0] == :args) }
index = (self_method_definition.index(args) + 1)
if (self_method_definition.length > (index + 1)) then
  body = self_method_definition[(index..-1)]
  body.insert(0, :block)
  body
else
  self_method_definition[index]
end
 end
   def self_method_arguments() args = self_method_definition.detect { |d| (d[0] == :args) }
args and (args.length > 1) ? (args[(1..-1)]) : ([])
 end
   def self_method_name() name = if self_method_definition[1].instance_of?(Symbol) then
  self_method_definition[1].to_s
else
  ((self_method_definition[1].select { |e| e.instance_of?(Symbol) }.map do |e|
    e.to_s
  end.join(".") + ".") + self_method_definition[2].to_s)
end
(if (defining_role.name == nil) then
  name
else
  ((("self_" + @defining_role.name.to_s) + "_") + name.to_s)
end).to_sym
 end
   def self_method_generate_source() AstRewritter.new(self_method_body, interpretation_context).rewrite!
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
   def self_definitions_generate(context_class) impl = ""
getters = []
@definitions.each do |role_name, role|
  line_no = role.name.!=(nil) ? (role.line_no) : (nil)
  role.methods.each do |name, method_sources|
    temp____defining_role = @defining_role
    @defining_role = role
    temp____method = @method
    @method = method_sources
    definition = self_method_generate_source
    (impl << ("   " + definition)) if definition
    @method = temp____method
    @defining_role = temp____defining_role
  end
  if role and role.name then
    if context_class.!=(nil) then
      context_class.class_eval(("attr_reader :" + role.name.to_s), role.file_name, line_no)
      line_no = (line_no + 1)
    else
      (getters << role.name)
    end
  end
  if context_class then
    if line_no then
      context_class.class_eval(impl, role.file_name, line_no)
    else
      context_class.class_eval(impl)
    end rescue raise(impl)
  end
end
unless context_class then
  if (getters.length > 0) then
    (impl << ("\n           attr_reader :" + getters.join(", :")))
  end
end
impl
 end

           attr_reader :private_interactions, :context_name, :method, :definitions, :defining_role
           end