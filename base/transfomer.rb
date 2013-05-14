context :Transformer do

  def initialize(context_name, roles, interactions, base_class,default_interaction)
    @context_name = context_name

    @roles = roles
    @interactions = interactions
    @base_class = base_class
    @default_interaction = default_interaction
  end

  role :context_name do end
  role :roles do
     def generated_source
       impl = ''
       getters = ''
       roles.each do |role, methods|
         getters << 'attr_reader :' + role.to_s + '
         '
         methods.each do |name, method_sources|
           bind :method => :method_sources, :method_name => :name, :defining_role => role
           definition = method.definition
           (impl << ('   ' + definition )) if definition
         end
       end
       (impl.strip! || '')+ '
' + (getters.strip!  || '') + '
'
     end
  end
  role :interactions do
    def generated_source
      internal_methods = ''
      external_methods = interactions.default
      interactions.each do |name, methods|
        methods.each do |method|
          bind :method => :method_sources, :method_name => :name, :defining_role => nil
          code = method.definition

          (method.is_private? ? internal_methods : external_methods) << ' ' << code
        end
      end
      (external_methods.strip! || '') + '
     private
' + (internal_methods.strip! || '') + '
'
    end
    def default
       if @default
         '
               def self.call(*args)
             arity = ' + name.to_s + '.method(:new).arity
             newArgs = args[0..arity-1]
             obj = ' + name.to_s + '.new *newArgs
             if arity < args.length
                 methodArgs = args[arity..-1]
                 obj.' + default.to_s + ' *methodArgs
             else
                obj.' + default.to_s + '
                             end
         end
            def call(*args);' + default.to_s + ' *args; end
'
       else
         ''
       end
    end
  end
  role :method_name do end
  role :defining_role do end
  role :method do
    def is_private?
      defining_role != nil || (private_interactions.has_key? method.name)
    end
    def definition
      return @def if @def
      unless (methods.instance_of? Array  && method_sources.length < 2) then
        raise(('Duplicate definition of ' + method_name.to_s))
      end
      unless (methods.instance_of? Array  && method_sources.length > 0) then
        raise(('No source for ' + method_name.to_s))
      end

      d = methods.instance_of? Array ? methods[0] : methods
      raise 'Sexp require' unless d.instance_of? Sexp
      @def = d
    end
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
      name = if definition[1].instance_of? Symbol
         definition[1].to_s
      else
        (definition[1].select { |e| e.instance_of? Symbol }.map { |e| e.to_s }.join('.') + '.' + definition[2].to_s)
      end
      (
      unless defining_role
        name
      else
        'self_' + @defining_role.to_s + '_' + name.to_s
      end).to_sym
    end
    def generated_source
      AstRewritter.new(method.body, interpretation_context).rewrite!
      body = Ruby2Ruby.new.process(method.body)
      raise 'Body is undefined' unless body
      args = method.arguments
      if args && args.length
        args = '('+ args.join(',') + ')'
      else
        args= ''
      end

      header = 'def ' + method.name.to_s + args
      header + ' ' + body + ' end'
    end
  end


  def transform(file_path, with_contracts)

    code = interactions.generated_source + roles.generated_source

    if file_path then
      name = context_name.to_s
      complete = ((((('class ' + name) + (@base_class ? (('<< ' + @base_class.name)) : (''))) + '
      ') + code.to_s) + '
           end')
      File.open((((('./' + file_path.to_s) + '/') + name) + '.rb'), 'w') do |f|
        f.write(complete)
      end
      complete
    else
      c = @base_class ? (Class.new(base_class)) : (Class.new)
      if with_contracts then
        c.class_eval(
            'def self.assert_that(obj)
  ContextAsserter.new(self.contracts,obj)
end
def self.refute_that(obj)
  ContextAsserter.new(self.contracts,obj,false)
end
def self.contracts
  @@contracts
end
def self.contracts=(value)
  @@contracts = value
end')
        c.contracts = contracts
      end
      Kernel.const_set(context_name, c)
      begin
        temp = c.class_eval(code)
      rescue SyntaxError
        p 'error: ' + code
      end

      (temp or c)
    end

  end

end
