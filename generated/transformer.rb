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
  File.open((((("./" + file_path.to_s) + "/") + name.underscore) + ".rb"), "w") do |f|
    f.write(complete)
  end
  complete
else
  if with_contracts then
    c.class_eval("def self.assert_that(obj)\n  ContextAsserter.new(self.contracts,obj)\nend\ndef self.refute_that(obj)\n  ContextAsserter.new(self.contracts,obj,false)\nend\ndef self.contracts\n  @contracts\nend\ndef self.contracts=(value)\n  @contracts = value\nend")
    c.contracts = contracts
  end
  Kernel.const_set(context_name, c)
  c
end

 end
   def contracts() @contracts

 end
   def role_aliases() @role_aliases

 end
   def interpretation_context() InterpretationContext.new(definitions, contracts, role_aliases, defining_role, @private_interactions)

 end
   def self_method_is_private?() ((not (defining_role == nil)) or private_interactions.has_key?(self_method_name))
 end
   def self_method_is_interaction?() ((defining_role == nil) or (defining_role.name == nil))
 end
   def self_method_definition() method

 end
   def self_method_line_no() @lines

 end
   def self_method_file_name() (@defining_role.file_name or "")
 end
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
   def self_method_generate_source(with_backtrace) AstRewritter.new(self_method_body, interpretation_context).rewrite!
body = Ruby2Ruby.new.process(self_method_body)
raise("Body is undefined") unless body
args = self_method_arguments
if args and args.length then
  args = (("(" + args.join(",")) + ")")
else
  args = ""
end
backtrace_rescue = if with_backtrace then
  (("\nrescue NoMethodError => e\n  begin\n    backtrace = e.backtrace\n    last = backtrace[0]\n    parts = last.split(\":\")\n    num = parts[1].to_\n    num = parts[2].to_i if num == 0\n    last[\":\#{num}:\"] = \":\#{num +" + @lines.to_s) + "}:\"\n    backtrace[0] = last\n    e.set_backtrace backtrace\n    raise e\n  rescue\n    raise e\n  end\n end\n")
else
  ""
end
header = (("def " + self_method_name.to_s) + args)
prefix = with_backtrace ? (" begin\n") : (" ")
method_source = ((((header + prefix) + body) + backtrace_rescue) + "\n end\n")
@lines = (@lines + method_source.lines.count(-(backtrace_rescue.lines.count + 1)))
method_source

 end
   def self_definitions_generate(context_class) impl = ""
getters = []
@definitions.each do |role_name, role|
  line_no = (not (role.name == nil)) ? (role.line_no) : (nil)
  @lines = (line_no or 0)
  role.methods.each do |name, method_sources|
    temp____defining_role = @defining_role
    @defining_role = role
    temp____method = @method
    @method = method_sources
    definition = self_method_generate_source((context_class and true))
    if context_class then
      begin
        context_class.class_eval(definition, role.file_name)
      rescue SyntaxError => e
        raise(((e.message + "\n") + definition))
      end
    end
    (impl << ("   " + definition)) if definition
    @method = temp____method
    @defining_role = temp____defining_role
  end
  if role and role.name then
    if (context_class == nil) then
      (getters << role.name)
    else
      context_class.class_eval(("attr_reader :" + role.name.to_s))
    end
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