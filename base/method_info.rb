context :MethodInfo do
  def initialize(ast, defining_role, is_private)
    raise('Must be S-Expressions') unless ast.instance_of?(Sexp)

    @defining_role = defining_role
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

    def name
        if definition[1].instance_of? Symbol
          definition[1]
        else
          (definition[1].select { |e| e.instance_of? Symbol }.map { |e| e.to_s }.join('.') + '.' + definition[2].to_s).to_sym
        end
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

    real_name = (if @defining_role == nil
                  name.to_s
                else
                  'self_' + @defining_role.to_s + '_' + name.to_s
                end).to_s
    header = 'def ' + real_name + args
    header + ' ' + body + ' end
'
  end
end