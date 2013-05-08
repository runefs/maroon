context :MethodInfo do
  def initialize(ast,name, is_private)
    raise('Must be S-Expressions') unless ast.instance_of?(Sexp)
    raise 'Needs name' unless name
    @name = name
    @private = is_private
    @definition = ast
    self.freeze

  end

  role :definition do
    def body
      args = definition.detect { |d| d[0] == :args }
      index = definition.index(args) + 1
      if definition.length > index+1
        body = definition[index..-1]
        body.insert(0, :block)
        body
      else
        definition[index]
      end
    end

    def arguments
      args = definition.detect { |d| d[0] == :args }
      args && args.length > 1 ? args[1..-1] : []
    end


  end

  def is_private
    @private
  end

  def name
    definition.name
  end

  def build_as_context_method(interpretation_context)
    AstRewritter.new(definition.body, interpretation_context).rewrite!
    body = Ruby2Ruby.new.process(definition.body)
    raise 'Body is undefined' unless body
    args = definition.arguments
    if args && args.length
      args = '('+ args.join(',') + ')'
    else
      args= ''
    end

    header = 'def ' + @name.to_s + args
    header + ' ' + body + ' end
'
  end
end