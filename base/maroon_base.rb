# -*- encoding: utf-8 -*-

##
# The Context class is used to define a DCI context with roles and their role methods
# to define a context call define with the name of the context (this name will become the name of the class that defines the context)
# the name should be a symbol and since it's going to be used as a class name, use class naming conventions
# follow the name with a block. With in this block you can define roles and interactions
# and interaction is defined by write the name of the interaction (hello in the below example) followed by a block
# the block will become the method body
# a role can be defined much like a context. instead of calling the define method call the role method followed by the role name (as a symbol)
# the role will be used for a private instance variable and the naming convention should match this
# With in the block supplied to the role method you can define role methods the same way as you define interactions. See the method who
# in the below example
# = Example
#    Context::define :Greeter do
#        role :who do
#          say do
#            @who #could be self as well to refer to the current role player of the 'who' role
#          end
#        end
#      greeting do
#        p 'Hello #{who.say}!'
#      end
#    end
#
#    class Greeter
#      def initialize(player)
#         #@who = player
#      end
#    end
#
#    Greeter.new('world').greeting #Will print 'Hello world!'
#maroon is base on Marvin which was the first injectionless language for DCI
#being injectionless there's no runtime extend or anything else impacting the performance. There' only regular method invocation even when using role methods
#Author:: Rune Funch Søltoft (funchsoltoft@gmail.com)
#License:: Same as for Ruby
##
c = context :Context do

  def self.define(*args, &block)
    @@with_contracts ||= nil
    @@generate_file_path ||= nil
    (alias :method_missing :role_or_interaction_method)

    base_class, ctx, default_interaction, name = self.send(:create_context_factory, args, block)
    if (args.last.instance_of?(FalseClass) or args.last.instance_of?(TrueClass)) then
      ctx.generate_files_in(args.last)
    end
    return ctx.send(:finalize, name, base_class, default_interaction, @@generate_file_path, @@with_contracts)

  end

  def self.generate_files_in(*args, &b)
    if block_given? then
      return role_or_interaction_method(:generate_files_in, *args, &b)
    end
    @@generate_file_path = args[0]

  end

  private

  def get_definitions(b)
    sexp = b.to_sexp
    unless is_definition? sexp[3]
      sexp = sexp[3]
      if sexp
        sexp = sexp.select do |exp|
          is_definition? exp
        end
      end
      sexp ||= []
    end

    sexp.select do |exp|
      is_definition? exp
    end
  end

  def self.create_context_factory(args, block)
    name, base_class, default_interaction = *args
    if default_interaction and (not base_class.instance_of?(Class)) then
      base_class = eval(base_class.to_s)
    end
    if base_class and ((not default_interaction) and (not base_class.instance_of?(Class))) then
      base_class, default_interaction = default_interaction, base_class
    end
    ctx = Context.new
    ctx.instance_eval {
      sexp = block.to_sexp
      temp_block = sexp[3]
      i = 0

      while i < temp_block.length
        exp = temp_block[i]
        unless temp_block[i-2] && temp_block[i-2][0] == :call && temp_block[i-1] && temp_block[i-1][0] == :args
          if exp[0] == :defn || exp[0] == :defs
            add_method(exp)
            temp_block.delete_at i
            i -= 1
          elsif exp[0] == :call && exp[1] == nil && exp[2] == :private
            @private = true
          end
        end
        i += 1
      end
      ctx.instance_eval &block
    }

    return [base_class, ctx, default_interaction, name]

  end

  def self.with_contracts(*args)
    return @@with_contracts if (args.length == 0)
    value = args[0]
    if @@with_contracts and (not value) then
      raise('make up your mind! disabling contracts during execution will result in undefined behavior')
    end
    @@with_contracts = value

  end

  def createInfo(definition)
    MethodInfo.new(definition, @defining_role, @private)
  end

  def is_definition?(exp)
    exp && (exp[0] == :defn || exp[0] == :defs)
  end

  def role(*args, &b)
    role_name = args[0]
    if (args.length.!=(1) or (not role_name.instance_of?(Symbol))) then
      return role_or_interaction_method(:role, *args, &b)
    end
    @defining_role = role_name
    @roles = {} unless @roles
    @roles[role_name] = Hash.new

    definitions = get_definitions(b)

    definitions.each do |exp|
      add_method(exp)
    end

  end

  def current_interpretation_context(*args, &b)
    if block_given? then
      return role_or_interaction_method(:current_interpretation_context, *args, &b)
    end
    InterpretationContext.new(@roles, @contracts, @role_alias, nil)

  end

  def get_methods(*args, &b)
    return role_or_interaction_method(:get_methods, *args, &b) if block_given?
    name = args[0]
    sources = (@defining_role ? (@roles[@defining_role]) : (@interactions))[name]
    if @defining_role and (not sources) then
      @roles[@defining_role][name] = []
    else
      @interactions[name] = []
    end

  end

  def add_method(*args, &b)
    return role_or_interaction_method(:add_method, *args, &b) if block_given?
    exp = args[0]
    info = createInfo exp
    sources = get_methods(info.name)
    (sources << info)
  end

  def finalize(*args, &b)
    return role_or_interaction_method(:finalize, *args, &b) if block_given?
    name, base_class, default, file_path, with_contracts = *args
    code = generate_context_code(default, name)
    if file_path then
      name = name.to_s
      complete = ((((('class ' + name) + (base_class ? (('<< ' + base_class.name)) : (''))) + '
      ') + code.to_s) + '
           end')
      File.open((((('./' + file_path.to_s) + '/') + name) + '.rb'), 'w') do |f|
        f.write(complete)
      end
      complete
    else
      c = base_class ? (Class.new(base_class)) : (Class.new)
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
      Kernel.const_set(name, c)
      begin
        temp = c.class_eval(code)
      rescue SyntaxError
        p 'error: ' + code
      end

      (temp or c)
    end

  end

  def generate_context_code(*args, &b)
    if block_given? then
      return role_or_interaction_method(:generate_context_code, *args, &b)
    end
    default, name = args
    getters = ''
    impl = ''
    interactions = ''
    @interactions.each do |method_name, methods|
      methods.each do |method|
        @defining_role = nil
        code = (' ' + method.build_as_context_method(current_interpretation_context))
        method.is_private ? ((getters << code)) : ((interactions << code))
      end
    end
    if default then
      (interactions << (((((((('
               def self.call(*args)
             arity = ' + name.to_s) + '.method(:new).arity
             newArgs = args[0..arity-1]
             obj = ') + name.to_s) + '.new *newArgs
             if arity < args.length
                 methodArgs = args[arity..-1]
                 obj.') + default.to_s) + ' *methodArgs
             else
                obj.') + default.to_s) + '
                             end
         end
         '))
      (interactions << (('
            def call(*args);' + default.to_s) + ' *args; end
'))
    end
    @roles.each do |role, methods|
      (getters << (('attr_reader :' + role.to_s) + '
      '))
      methods.each do |method_name, method_sources|
        unless (method_sources.length < 2) then
          raise(('Duplicate definition of ' + method_name.to_s))
        end
        unless (method_sources.length > 0) then
          raise(('No source for ' + method_name.to_s))
        end
        method_source = method_sources[0]
        @defining_role = role

        definition = method_source.build_as_context_method(current_interpretation_context)
        (impl << ('   ' + definition.to_s)) if definition
      end
    end
    private_string = (getters + impl).strip! != '' ? '
     private
' : ''
    impl = impl.strip! != '' ? '
    ' + impl + '
    ' : '
    '
    interactions + private_string + getters + impl

  end

  def role_or_interaction_method(*arguments, &b)
    method_name, on_self = *arguments
    unless method_name.instance_of?(Symbol) then
      on_self = method_name
      method_name = :role_or_interaction_method
    end
    raise(('Method with out block ' + method_name.to_s)) unless block_given?

  end


  def initialize
    @roles = {}
    @interactions = {}
    @role_alias = {}
  end

end

if c.instance_of? String
  file_name = './generated/Context.rb'
  p "writing to: " + file_name
  File.open(file_name, 'w') do |f|
    f.write(c)
  end
end
