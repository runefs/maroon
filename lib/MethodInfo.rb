class MethodInfo
       def initialize(ast,defining_role,is_private) raise("Must be S-Expressions") unless ast.instance_of?(Sexp)
@defining_role = defining_role
@private = is_private
@definition = ast
self.freeze
 end
 def is_private() @private end
 def name() self_definition_name end
 def build_as_context_method(interpretation_context) AstRewritter.new(self_definition_body, interpretation_context).rewrite!
body = Ruby2Ruby.new.process(self_definition_body)
raise("Body is undefined") unless body
args = self_definition_arguments
if args and args.length then
  args = (("(" + args.join(",")) + ")")
else
  args = ""
end
real_name = (if (@defining_role == nil) then
  name.to_s
else
  ((("self_" + @defining_role.to_s) + "_") + name.to_s)
end).to_s
header = (("def " + real_name) + args)
(((header + " ") + body) + " end\n")
 end

     private
attr_reader :definition
      
    def self_definition_body() args = definition.detect { |d| (d[0] == :args) }
index = (definition.index(args) + 1)
if (definition.length > (index + 1)) then
  body = definition[(index..-1)]
  body.insert(0, :block)
  body
else
  definition[index]
end
 end
   def self_definition_arguments() args = definition.detect { |d| (d[0] == :args) }
args and (args.length > 1) ? (args[(1..-1)]) : ([])
 end
   def self_definition_name() if definition[1].instance_of?(Symbol) then
  definition[1]
else
  ((definition[1].select { |e| e.instance_of?(Symbol) }.map { |e| e.to_s }.join(".") + ".") + definition[2].to_s).to_sym
end end
    
           end