context :AbstractSyntaxTree do
  role :interpretation_context do
  end
  role :queue do
  end

  role :production do
    def is_role?
      case
        when (production.is_call? && (interpretation_context.methods.has_key?(production[2])))
          @data = [interpretation_context.methods[production[2]]]
          true
        when (production == :self ||
             (production.is_indexer? && (production[1] == nil || production[1] == :self)) ||
             (production && ((production.instance_of?(Sexp) || production.instance_of?(Array)) && production[0] == :self))) && @interpretation_context.defining_role

          @data = [@interpretation_context.defining_role]
          true
        else
          false
      end
    end

    def is_indexer?
      production.is_call? && (production[2] == :[] || production[2] == :[]=)
    end

    def is_call?
      can_be = production && ((production.instance_of?(Sexp) || production.instance_of?(Array)) && (production[0] == :call))
      @data = [production[2]] if can_be
      can_be
    end

    def is_block?
      production && ((production.instance_of?(Sexp) || production.instance_of?(Array)) && production[0] == :iter)
    end

    def is_block_with_bind?
      if production.is_block?
        body = @production.last()
        if body and exp = (body[1] || body)
          bind = AbstractSyntaxTree.new(exp, @interpretation_context)
          if (bind.type == Tokens.call) and (bind.data == [:bind])
            aliases = {}
            # list = exp.last[(1..-1)] 
            # sourcify 0.5.0 returns s(s(:lit, :p), s(:lit, :role_name))
            # while sourcify 0.6.0 returns s(s(:hash, s(:lit, :p), s(:lit, :role_name)))
            list = exp.last[(1..-1)].value[(1..-1)] # compatible with sourcify 0.6.0

            (list.length/2).times{|i|
              local = list[i*2].last
              role_name = list[i*2+1].last
              raise 'Local in bind should be a symbol' unless local.instance_of? Symbol
              raise 'Role name in bind should be a symbol' unless role_name.instance_of? Symbol
              aliases[local] = role_name
            }
            @data = aliases
            true
          end
        end
      end
    end
    def is_const?
      if production.instance_of?(Sexp) && production.length == 2 && production[0] == :const && (production[1].instance_of? Symbol)
        @data = [production[1]]
        true
      else
        false
      end
    end
    def is_initializer?
      if production.is_call?
        if AbstractSyntaxTree.new(production[1], @interpretation_context).type == Tokens::const
           if production[2] == :new
             return true
           end
        end
      end
      false
    end
    def is_rolemethod_call?
      can_be = production.is_call?
      if can_be
        instance = AbstractSyntaxTree.new(production[1], @interpretation_context)
        can_be = instance.type == Tokens::role
        if can_be
          role = instance.data[0]
          method_name = production[2]
          can_be = role && role.method_defined?(method_name)
          @data = [method_name, role.name] if can_be
        end
      end
      can_be
    end
  end

  def initialize(ast, interpretation_context)
    rebind ImmutableQueue::empty.push(ast), interpretation_context
  end

  def type
    case
      when nil == production
        nil
      when production.is_block_with_bind?
        Tokens::block_with_bind
      when production.is_block?
        Tokens::block
      when production.instance_of?(Fixnum) || production.instance_of?(Symbol)
        Tokens::terminal
      when production.is_rolemethod_call?
        Tokens::rolemethod_call
      when production.is_role?
        Tokens::role
      when production.is_indexer?
        Tokens::indexer
      when production.is_const?
        Tokens::const
      when production.is_initializer?
        Tokens::initializer
      when production.is_call?
        Tokens::call
      else
        Tokens::other
    end
  end

  def [](i)
    @production[i]
  end

  def []=(i, v)
    @production[i]=v
  end

  def length
    @production.length
  end

  def last
    @production.last
  end

  def first
    @production.first
  end

  def data
    return @data if @data
    @data = case
              when production.is_call?
                @production[2]
              else
                @production
            end
  end

  def each_production
    yield self
    if production.instance_of? Sexp || production.instance_of?(Array)
      @queue = @queue.push_array production
    end
    while @queue != ImmutableQueue::empty
      rebind @queue, @interpretation_context
      yield self
      if production.instance_of? Sexp || production.instance_of?(Array)
        @queue = @queue.push_array production
      end
    end
  end

  private

  def rebind(queue, ctx)
    @data = nil
    @production, @queue = queue.pop
    @interpretation_context = ctx
  end

end