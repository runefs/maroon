context :MethodInfo do
  initialize do |on_self, block_source, is_private|
    raise 'Must be S-Expressions' unless block_source.instance_of? Sexp

    if on_self.instance_of? Hash
      @block = on_self[:block]
      @on_self = on_self[:self]
    else
      @on_self = on_self
    end
    @block_source = block_source
    @private = is_private
    self.freeze

  end

  role :on_self do
  end

  role :block do
  end

  role :block_source do
    get_arguments do
      sexp = block_source[2]
      return nil unless sexp
      return sexp[1] if sexp[0] == :lasgn
      return [] if sexp[1] == nil
      sexp = sexp[1..-1]
      args = []
      sexp.each do |e|
        args << if e.instance_of? Symbol
                  e
                else
                  if e[0] == :splat
                    '*' + e[1][1].to_s
                  else
                    e[1]
                  end
                end
      end

      if block
        b = '&' + block.to_s
        if args
          unless args.instance_of? Array
            args = [args]
          end
          args << b
        else
          args = [b]
        end
      end
      args
    end
    arguments do
      args = @block_source.get_arguments
      args && args.length ? args.join(',') : nil
    end
    body do
      block_source[3]
    end
  end

  is_private do
    @private
  end

  build_as_context_method do |context_method_name, interpretation_context|
    MethodDefinition.new(block_source.body, interpretation_context).transform
    body = Ruby2Ruby.new.process(block_source.body)
    args = block_source.arguments ? '(' + block_source.arguments + ')' : ""
    on = if on_self then
           'self.'
         else
           ''
         end
    '
def ' + on.to_s + context_method_name.to_s + args +'
    ' + body +'
 end
'
  end
end