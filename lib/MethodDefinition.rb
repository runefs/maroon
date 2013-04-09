class MethodDefinition
       
def rebind()
    @exp, @expressions = expressions.pop
@block, @potential_bind = nil
if @exp and (@exp.instance_of?(Sexp) and (@exp[0] == :iter)) then
  @exp[(1..-1)].each do |expr|
    if expr and (expr.length and (expr[0] == :block)) then
      @block, @potential_bind = expr, expr[1]
    end
  end
end
@expressions = @exp.instance_of?(Sexp) ? (@expressions.push_array(exp)) : (@expressions)

 end
 
def transform()
    until self_expressions_empty? do
  (self_block_transform
  if exp and exp.instance_of?(Sexp) then
    is_indexer = ((exp[0] == :call) and ((exp[1] == nil) and ((exp[2] == :[]) or (exp[2] == :[]=))))
    if (is_indexer or (exp[0] == :self)) and @interpretation_context.defining_role then
      Self.new(exp, interpretation_context).execute
    end
    if (exp[0] == :call) then
      MethodCall.new(exp, interpretation_context).rewrite_call?
    end
  end
  rebind)
end
 end
 
def initialize(exp,interpretationcontext)
    no_exp = "No expression supplied".to_sym
no_ctx = "No interpretation context".to_sym
raise(no_exp) unless exp
raise(no_ctx) unless interpretationcontext
@interpretation_context = interpretationcontext
@expressions = ImmutableQueue.empty.push(exp)
rebind

 end

         def self.call(*args)
             arity = MethodDefinition.method(:new).arity
             newArgs = args[0..arity-1]
             obj = MethodDefinition.new *newArgs
             if arity < args.length
                 methodArgs = args[arity..-1]
                 obj.transform *methodArgs
             else
                obj.transform
             end
         end
         
      def call(*args);transform *args; end

 private
attr_reader :interpretation_context
      attr_reader :exp
      attr_reader :expressions
      attr_reader :potential_bind
      attr_reader :block
      
       
def self_interpretation_context_addalias(key,value)
    @interpretation_context.role_aliases[key] = value
 end
   
def self_expressions_empty?()
    (expressions == ImmutableQueue.empty)
 end
   
def self_potential_bind_is_bind?()
    potential_bind and (potential_bind.length and ((potential_bind[0] == :call) and ((potential_bind[1] == nil) and (potential_bind[2] == :bind))))
 end
   
def self_block_transform()
    if block then
  @expressions.push_array(block[(1..-1)]) if self_block_transform_bind?
end
 end
   
def self_block_transform_bind?()
    self_potential_bind_is_bind? and self_block_rewrite
 end
   
def self_block_rewrite()
    changed = false
arguments = potential_bind[3]
if arguments and (arguments[0] == :hash) then
  block.delete_at(1)
  count = ((arguments.length - 1) / 2)
  (1..count).each do |j|
    temp = (j * 2)
    local = arguments[(temp - 1)][1]
    local = local[1] if local.instance_of?(Sexp)
    raise("invalid value for role alias") unless local.instance_of?(Symbol)
    aliased_role = arguments[temp][1]
    aliased_role = aliased_role[1] if aliased_role.instance_of?(Sexp)
    unless aliased_role.instance_of?(Symbol) and interpretation_context.roles.has_key?(aliased_role) then
      raise(((aliased_role.to_s + "used in binding is an unknown role ") + roles.to_s))
    end
    self_interpretation_context_addalias(local, aliased_role)
    Bind.new(local, aliased_role, block).execute
    changed = true
  end
end
changed

 end

    
      end