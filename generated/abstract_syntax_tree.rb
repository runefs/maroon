class AbstractSyntaxTree
         def initialize(ast,interpretation_context) rebind(ImmutableQueue.empty.push(ast), interpretation_context)

 end
   def type() case
when (nil == production) then
  nil
when self_production_is_block_with_bind? then
  Tokens.block_with_bind
when self_production_is_block? then
  Tokens.block
when (production.instance_of?(Fixnum) or production.instance_of?(Symbol)) then
  Tokens.terminal
when self_production_is_rolemethod_call? then
  Tokens.rolemethod_call
when self_production_is_role? then
  Tokens.role
when self_production_is_indexer? then
  Tokens.indexer
when self_production_is_const? then
  Tokens.const
when self_production_is_initializer? then
  Tokens.initializer
when self_production_is_call? then
  Tokens.call
else
  Tokens.other
end

 end
   def [](i) @production[i]

 end
   def []=(i,v) @production[i] = v

 end
   def length() @production.length

 end
   def last() @production.last

 end
   def first() @production.first

 end
   def data() return @data if @data
@data = case
when self_production_is_call? then
  @production[2]
else
  @production
end

 end
   def each_production() yield(self)
if production.instance_of?((Sexp or production.instance_of?(Array))) then
  @queue = @queue.push_array(production)
end
until (@queue == ImmutableQueue.empty) do
  (rebind(@queue, @interpretation_context)
  yield(self)
  if production.instance_of?((Sexp or production.instance_of?(Array))) then
    @queue = @queue.push_array(production)
  end)
end

 end
   def rebind(queue,ctx) @data = nil
@production, @queue = queue.pop
@interpretation_context = ctx

 end
   def self_production_is_role?() case
when (self_production_is_call? and interpretation_context.methods.has_key?(production[2])) then
  @data = [interpretation_context.methods[production[2]]]
  true
when (((production == :self) or ((self_production_is_indexer? and ((production[1] == nil) or (production[1] == :self))) or (production and ((production.instance_of?(Sexp) or production.instance_of?(Array)) and (production[0] == :self))))) and @interpretation_context.defining_role) then
  @data = [@interpretation_context.defining_role]
  true
else
  false
end

 end
   def self_production_is_indexer?() (self_production_is_call? and ((production[2] == :[]) or (production[2] == :[]=)))
 end
   def self_production_is_call?() can_be = (production and ((production.instance_of?(Sexp) or production.instance_of?(Array)) and (production[0] == :call)))
@data = [production[2]] if can_be
can_be

 end
   def self_production_is_block?() (production and ((production.instance_of?(Sexp) or production.instance_of?(Array)) and (production[0] == :iter)))
 end
   def self_production_is_block_with_bind?() if self_production_is_block? then
  body = @production.last
  if body and exp = (body[1] or body) then
    bind = AbstractSyntaxTree.new(exp, @interpretation_context)
    if (bind.type == Tokens.call) and (bind.data == [:bind]) then
      aliases = {  }
      list = exp.last[(1..-1)].value[(1..-1)]
      (list.length / 2).times do |i|
        local = list[(i * 2)].last
        role_name = list[((i * 2) + 1)].last
        raise("Local in bind should be a symbol") unless local.instance_of?(Symbol)
        unless role_name.instance_of?(Symbol) then
          raise("Role name in bind should be a symbol")
        end
        aliases[local] = role_name
      end
      @data = aliases
      true
    end
  end
end

 end
   def self_production_is_const?() if production.instance_of?(Sexp) and ((production.length == 2) and ((production[0] == :const) and production[1].instance_of?(Symbol))) then
  @data = [production[1]]
  true
else
  false
end

 end
   def self_production_is_initializer?() if self_production_is_call? then
  if (AbstractSyntaxTree.new(production[1], @interpretation_context).type == Tokens.const) then
    return true if (production[2] == :new)
  end
end
false

 end
   def self_production_is_rolemethod_call?() can_be = self_production_is_call?
if can_be then
  instance = AbstractSyntaxTree.new(production[1], @interpretation_context)
  can_be = (instance.type == Tokens.role)
  if can_be then
    role = instance.data[0]
    method_name = production[2]
    can_be = (role and role.method_defined?(method_name))
    @data = [method_name, role.name] if can_be
  end
end
can_be

 end

           attr_reader :interpretation_context, :queue, :production
           end