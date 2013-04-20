class Production

  def initialize(ast, interpretation_context)
    rebind(ImmutableQueue.empty.push(ast), interpretation_context)
  end

  def type()
    case
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
      when self_production_is_call? then
        Tokens.call
      else
        Tokens.other
    end
  end

  def [](i)
    @production[i]
  end

  def []=(i, v)
    @production[i] = v
  end

  def length()
    @production.length
  end

  def last()
    @production.last
  end

  def first()
    @production.first
  end

  def data()
    return @data if @data
    @data = case
              when self_production_is_call? then
                @production[2]
              else
                @production
            end

  end

  def each()
    yield(self)
    if production.instance_of?((Sexp or production.instance_of?(Array))) then
      @queue = @queue.push_array(production)
    end
    while @queue.!=(ImmutableQueue.empty) do
      rebind(@queue, @interpretation_context)
      yield(self)
      if production.instance_of?((Sexp or production.instance_of?(Array))) then
        @queue = @queue.push_array(production)
      end
    end

  end

  private

  def rebind(queue, ctx)
    @data = nil
    @production, @queue = queue.pop
    @interpretation_context = ctx

  end

  attr_reader :interpretation_context
  attr_reader :queue
  attr_reader :production


  def self_production_is_role?()
    case
      when (self_production_is_call? and interpretation_context.roles.has_key?(production[2])) then
        @date = [production[2]]
        return true
      when (((production == :self) or ((self_production_is_indexer? and ((production[1] == nil) or (production[1] == :self))) or (production and ((production.instance_of?(Sexp) or production.instance_of?(Array)) and (production[0] == :self))))) and @interpretation_context.defining_role) then
        @data = @interpretation_context.defining_role
        return true
      else
        false
    end
  end

  def self_production_is_indexer?()
    self_production_is_call? and ((production[2] == :[]) or (production[2] == :[]=))
  end

  def self_production_is_call?()
    production and ((production.instance_of?(Sexp) or production.instance_of?(Array)) and (production[0] == :call))
  end

  def self_production_is_block?()
    production and ((production.instance_of?(Sexp) or production.instance_of?(Array)) and (production[0] == :iter))
  end

  def self_production_is_block_with_bind?()
    if self_production_is_block? then
      body = @production.last
      if body and exp = body[0] then
        bind = Production.new(exp, @interpretation_context)
        true if (bind.type == Tokens.call) and (bind.data == :bind)
      end
    end
  end

  def self_production_is_rolemethod_call?()
    can_be = self_production_is_call?
    if can_be then
      instance = Production.new(production[1], @interpretation_context)
      can_be = (instance.type == Tokens.role)
      if can_be then
        instance_data = instance.data
        role = @interpretation_context.roles[instance_data]
        data = production[2]
        can_be = role.has_key?(data)
        @data = [data, instance_data]
      end
    end
    can_be

  end


end