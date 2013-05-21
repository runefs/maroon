class MethodInfo
  def initialize(ast, name, is_private)
    raise("Must be S-Expressions") unless ast.instance_of?(Sexp)
    raise("Needs name") unless name
    @name = name
    @private = is_private
    @definition = ast
    self.freeze
  end

  def is_private()
    @private
  end

  def name()
    definition.name
  end

  def build_as_context_method(interpretation_context)
    AstRewritter.new(self_definition_body, interpretation_context).rewrite!
    body = Ruby2Ruby.new.process(self_definition_body)
    raise("Body is undefined") unless body
    args = self_definition_arguments
    if args and args.length then
      args = (("(" + args.join(",")) + ")")
    else
      args = ""
    end
    header = (("def " + @name.to_s) + args)
    (((header + " ") + body) + " end\n")
  end

  private
  attr_reader :definition

  def self_definition_body()
    args = definition.detect { |d| (d[0] == :args) }
    index = (definition.index(args) + 1)
    if (definition.length > (index + 1)) then
      body = definition[(index..-1)]
      body.insert(0, :block)
      body
    else
      definition[index]
    end
  end

  def self_definition_arguments()
    args = definition.detect { |d| (d[0] == :args) }
    args and (args.length > 1) ? (args[(1..-1)]) : ([])
  end

end