
Context::generate_dependency_graph = {}
c = context(:Transformer) {||
  def initialize(context_name, definitions,private_interactions, base_class,default_interaction)
    raise 'No method definitions to transform' if definitions.length == 0
    @context_name = context_name
    @definitions = definitions
    @base_class = base_class
    @default_interaction = default_interaction
    @private_interactions = private_interactions
  end

  role :private_interactions do end
  role :context_name do end

  role :method do
    def is_private?
      defining_role != nil || (private_interactions.has_key? method.name)
    end
    def is_interaction?
      (defining_role == nil) || (defining_role.name == nil)
    end
    def definition
      method
    end
    def line_no
      @lines
    end
    def file_name
      @defining_role.file_name || ''
    end
    def body
      args = method.definition.detect { |d| d[0] == :args }
      index = method.definition.index(args) + 1
      if method.definition.length > index+1
        body = method.definition[index..-1]
        body.insert(0, :block)
        body
      else
        method.definition[index]
      end
    end

    def arguments
      args = method.definition.detect { |d| d[0] == :args }
      args && args.length > 1 ? args[1..-1] : []
    end

    def name
      name = if method.definition[1].instance_of? Symbol
               method.definition[1].to_s
             else
               (method.definition[1].select { |e| e.instance_of? Symbol }.map { |e| e.to_s }.join('.') + '.' + method.definition[2].to_s)
             end
      (
      if defining_role.name == nil  # it's an interaction
        name
      else
        'self_' + @defining_role.name.to_s + '_' + name.to_s
      end).to_sym
    end
    def generate_source(with_backtrace)
      AstRewritter.new(method.body, interpretation_context).rewrite!
      body = Ruby2Ruby.new.process(method.body)
      raise 'Body is undefined' unless body
      args = method.arguments
      if args && args.length
        args = '('+ args.join(',') + ')'
      else
        args= ''
      end
      backtrace_rescue = with_backtrace ? ('
rescue NoMethodError => e
  begin
    backtrace = e.backtrace
    last = backtrace[0]
    parts = last.split(":")
    num = parts[1].to_
    num = parts[2].to_i if num == 0
    last[":#{num}:"] = ":#{num +' + @lines.to_s + '}:"
    backtrace[0] = last
    e.set_backtrace backtrace
    raise e
  rescue
    raise e
  end
 end
') : ''
      header = 'def ' + method.name.to_s + args
      prefix = with_backtrace ? ' begin
' : ' '
      method_source = header + prefix + body + backtrace_rescue + '
 end
'
      @lines += method_source.lines.count -(backtrace_rescue.lines.count + 1)
      method_source
    end
  end

  role(:definitions) {
     def generate(context_class)
       impl = ''
       getters = []

       @definitions.each do |role_name, role|
         line_no = (role.name != nil) ? role.line_no : nil
         @lines = line_no || 0
         role.methods.each do |name, method_sources|
           bind :method_sources => :method ,  role => :defining_role

           definition = method.generate_source(context_class && true)
           if context_class
             begin
               context_class.class_eval(definition,role.file_name)
             rescue SyntaxError => e
               raise (e.message + '
' + definition)
             end
           end
           (impl << ('   ' + definition )) if definition
         end
         if role && role.name
           if context_class != nil
             context_class.class_eval('attr_reader :' + role.name.to_s)
           else
             getters << role.name
           end
         end

       end
       unless context_class
         (impl << '
           attr_reader :' + getters.join(', :')) if getters.length > 0
       end
       impl
     end
  }

  role :defining_role do end

  def transform(file_path, with_contracts)
    c = file_path ? nil : (@base_class ? (Class.new(base_class)) : (Class.new))
    code = definitions.generate c
    if file_path
      name = context_name.to_s
      complete = ((((('class ' + name) + (@base_class ? (('<< ' + @base_class.name)) : (''))) + '
      ') + code.to_s) + '
           end')       
    
      File.open((((('./' + file_path.to_s) + '/') + name.underscore) + '.rb'), 'w') do |f|
        f.write(complete)
      end
      complete
    else
      if with_contracts then
        c.class_eval(
            'def self.assert_that(obj)
  ContextAsserter.new(self.contracts,obj)
end
def self.refute_that(obj)
  ContextAsserter.new(self.contracts,obj,false)
end
def self.contracts
  @contracts
end
def self.contracts=(value)
  @contracts = value
end')
        c.contracts = contracts
      end
      Kernel.const_set(context_name, c)
      c
      end
  end


  private

  def contracts
    @contracts
  end
  def role_aliases
    @role_aliases
  end
  def interpretation_context
    InterpretationContext.new(definitions, contracts, role_aliases, defining_role, @private_interactions)
  end
}

# p ctx.dependencies.to_dot
# 
# context_class_code = c.generated_class
# 
# if context_class_code.instance_of? String
#   file_name = './generated/transformer.rb'
#   p "writing to: " + file_name
#   File.open(file_name, 'w') do |f|
#     f.write(context_class_code)
#   end
# end
# 
