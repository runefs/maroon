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
#        p "Hello #{who.say}!"
#      end
#    end
#
#    class Greeter
#      def initialize(player)
#         #@who = player
#      end
#    end
#
#    Greeter.new('world').greeting #Will print "Hello world!"
#maroon is base on Marvin which was the first injectionless language for DCI
#being injectionless there's no runtime extend or anything else impacting the performance. There' only regular method invocation even when using role methods
#Author:: Rune Funch Søltoft (funchsoltoft@gmail.com)
#License:: Same as for Ruby
##
Context::generate_files_in 'generated'
context :Context do
  role :roles do
  end
  role :interactions do
  end
  role :defining_role do
  end
  role :role_alias do
  end
  role :alias_list do
  end
  role :cached_roles_and_alias_list do
  end

  #define is the only exposed method and can be used to define a context (class)
  #if maroon/kernel is required calling context of Context::define are equivalent
  #params
  #name:: the name of the context. Since this is used as the name of a class, class naming convetions should be used
  #block:: the body of the context. Can include definitions of roles (through the role method) or definitions of interactions
  #by simply calling a method with the name of the interaction and passing a block as the body of the interaction
  define :block => :block, :self => self do |*args|
    @@with_contracts ||= nil
    @@generate_file_path ||= nil
    alias method_missing role_or_interaction_method
    base_class, ctx, default_interaction, name = self.send(:create_context_factory, args, block)
    ctx.generate_files_in(args.last()) if args.last().instance_of? FalseClass or args.last().instance_of? TrueClass
    return ctx.send(:finalize, name, base_class, default_interaction)
  end

  generate_files_in :block => :b,:self => self do |*args|
    return role_or_interaction_method(:generate_files_in, *args, &b) if block_given?

    @@generate_file_path = args[0]
  end

  private
  with_contracts self do |*args|
    return @@with_contracts if args.length == 0
    value = args[0]
    raise 'make up your mind! disabling contracts during execution will result in undefined behavior' if @@with_contracts && !value
    @@with_contracts = value
  end

  ##
  #Defines a role with the given name
  #role methods can be defined inside a block passed to this method
  # = Example
  #       role :who do
  #          say do
  #            p @who
  #          end
  #       end
  #The above code defines a role called 'who' with a role method called say
  ##
  role :block => :b do |*args|
    role_name = args[0]
    return role_or_interaction_method(:role, *args, &b) if args.length != 1 or not (role_name.instance_of? Symbol)

    @defining_role = role_name
    @roles[role_name] = Hash.new


  end

  role_or_interaction_method(:private)  do
    @private = true
  end

  current_interpretation_context :block => :b do |*args|
    return role_or_interaction_method(:current_interpretation_context, *args, &b) if block_given?
    InterpretationContext.new(roles, contracts, role_alias, nil)
  end

  get_methods :block => :b do |*args|
    return role_or_interaction_method(:get_methods, *args, &b) if block_given?
    name = args[0]
    sources = (@defining_role ? (@roles[@defining_role]) : (@interactions))[name]
    if @defining_role && !sources
      @roles[@defining_role][name] = []
    else
      (@interactions)[name] = []
    end
  end

  role :contracts do
  end

  add_method :block => :b do |*args|
    return role_or_interaction_method(:add_method, *args, &b) if block_given?
    name, method = *args
    sources = get_methods(name)
    sources << method
  end

  finalize :block => :b do |*args|
    return role_or_interaction_method(:finalize, *args, &b) if block_given?
    name, base_class, default = *args

    code = generate_context_code(default, name)

    if @@generate_file_path
      name = name.to_s
      complete = 'class ' + name + (base_class ? '<< ' + base_class.name : '') + '
      ' + code.to_s + '
      end'
      File.open('./' + @@generate_file_path.to_s + '/' + name + '.rb', 'w') { |f| f.write(complete) }
      complete
    else

      c = base_class ? (Class.new base_class) : Class.new
      if @@with_contracts
        c.class_eval('def self.assert_that(obj)
          ContextAsserter.new(self.contracts,obj)
        end
        def self.refute_that(obj)
          ContextAsserter.new(self.contracts,obj,false)
        end
        def self.contracts
          @@contracts
        end
        def self.contracts=(value)
          raise \'Contracts must be supplied\' unless value
          @@contracts = value
        end')
        c.contracts=contracts
      end
      Kernel.const_set name, c
      temp = c.class_eval(code)
      (temp || c)
    end
  end

  create_context_factory self do |args, block|
    name, base_class, default_interaction = *args
    #if there's two arguments and the second is not a class it must be an interaction
    if default_interaction && (!base_class.instance_of? Class) then
      base_class = eval(base_class.to_s)
    end
    base_class, default_interaction = default_interaction, base_class if base_class and !default_interaction and !base_class.instance_of? Class
    ctx = Context.new
    ctx.instance_eval &block
    return base_class, ctx, default_interaction, name
  end

  generate_context_code :block => :b do |*args|
    return role_or_interaction_method(:generate_context_code, *args, &b) if block_given?
    default, name = args

    getters = ''
    impl = ''
    interactions = ''
    @interactions.each do |method_name, methods|
      methods.each do |method|
        @defining_role = nil
        code = ' ' + (method.build_as_context_method method_name, current_interpretation_context)
        if method.is_private
          getters << code
        else
          interactions << code
        end
      end
    end

    if default
      interactions << '
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
         '
      interactions << '
      def call(*args);' + default.to_s + ' *args; end
'
    end

    @roles.each do |role, methods|
      getters << 'attr_reader :' + role.to_s + '
      '

      methods.each do |method_name, method_sources|
        raise 'Duplicate definition of ' + method_name.to_s unless method_sources.length < 2
        raise 'No source for ' + method_name.to_s unless method_sources.length > 0

        method_source = method_sources[0]
        @defining_role = role
        rewritten_method_name = 'self_' + role.to_s + '_' + method_name.to_s
        definition = method_source.build_as_context_method rewritten_method_name, current_interpretation_context
        (impl << '   ' + definition.to_s) if definition
      end
    end


    interactions + '
 private
' + getters + '
    ' + impl + '
    '
  end

  role_or_interaction_method({:block => :b}) do |*arguments|
    method_name, on_self = *arguments
    unless method_name.instance_of? Symbol
      on_self = method_name
      method_name = :role_or_interaction_method
    end

    raise 'Method with out block ' + method_name.to_s unless block_given?

    add_method(method_name, MethodInfo.new(on_self, b.to_sexp, @private))
  end
end