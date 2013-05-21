context :Production do
  role :interpretation_context do
  end
  role :queue do
  end

  role :production do
    def is_role?

      case
        when production.is_call? && (interpretation_context.roles.has_key?(production[2]))
          @date = [production[2]]
          return true
        when (production == :self ||
            (production.is_indexer? && (production[1] == nil || production[1] == :self)) ||
            (production && ((production.instance_of?(Sexp) || production.instance_of?(Array)) && production[0] == :self))) && @interpretation_context.defining_role
          @data = @interpretation_context.defining_role
          return true
        else
          false
      end
    end

    def is_indexer?
      production.is_call? && (production[2] == :[] || production[2] == :[]=)
    end

    def is_call?
      production && ((production.instance_of?(Sexp) || production.instance_of?(Array)) && production[0] == :call)
    end

    def is_block?
      production && ((production.instance_of?(Sexp) || production.instance_of?(Array)) && production[0] == :iter)
    end

    def is_block_with_bind?
      if production.is_block?
        body = @production.last()
        if body && (exp = body[1])
          bind = Production.new exp, @interpretation_context
          if bind.type == Tokens::call && bind.data == :bind
            aliases = {}
            list = exp.last[1..-1]
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

    def is_rolemethod_call?
      can_be = production.is_call?
      if can_be
        instance = Production.new(production[1], @interpretation_context)
        can_be = instance.type == Tokens::role
        if can_be
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

  def each
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