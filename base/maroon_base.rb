# -*- encoding: utf-8 -*-
require_relative 'method_info.rb'

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
class Context_base
  @roles
  @interactions
  @defining_role
  @role_alias
  @alias_list
  @cached_roles_and_alias_list
  @@with_contracts = false
  @generate_file
  @@generate_file

  #define is the only exposed method and can be used to define a context (class)
  #if maroon/kernel is required calling context of Context::define are equivalent
  #params
  #name:: the name of the context. Since this is used as the name of a class, class naming convetions should be used
  #block:: the body of the context. Can include definitions of roles (through the role method) or definitions of interactions
  #by simply calling a method with the name of the interaction and passing a block as the body of the interaction
  def self.define(*args, &block)
    base_class, ctx, default_interaction, name = self.send(:create_context_factory, args, block)
    ctx.generate_file = args.last() if args.last().instance_of? FalseClass or args.last().instance_of? TrueClass
    return ctx.send(:finalize, name, base_class, default_interaction)
  end

  def self.generate_file=(value)
    @@generate_file = value && true
  end

  def self.with_contracts=(value)
    raise 'make up your mind! disabling contracts during execution will result in undefined behavior' if @@with_contracts && !value
    @@with_contracts = value
  end

  def self.with_contracts
    @@with_contracts
  end

  private
  def generate_file=(value,&b)
    if block_given?
      role_or_interaction_method(:generate_file=,&b)
    else
      @generate_file = value
    end
  end
  def generate_file
    if block_given?
      role_or_interaction_method(:generate_file,&b)
    else
      @generate_file || @@generate_file
    end
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
  def role(role_name)
    raise 'Argument role_name must be a symbol' unless role_name.instance_of? Symbol

    @defining_role = role_name
    @roles[role_name] = Hash.new
    yield if block_given?
    @defining_role = nil
  end

  def initialize
    if block_given?
      return role_or_interaction_method(:initialize,&b)
    end
      @roles = Hash.new
      @interactions = Hash.new
      @role_alias = Array.new
  end

  def methods
    if block_given?
      role_or_interaction_method(:methods,&b)
    else
      (@defining_role ? @roles[@defining_role] : @interactions)
    end
  end

  def finalize(name, base_class, default)
    if block_given?
      return role_or_interaction_method(:finalize,&b)
    end
    c = base_class ? (Class.new base_class) : Class.new
    Kernel.const_set name, c
    code = generate_context_code(default, name)
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
      c.contracts={} #self.contracts
    end
    if generate_file
      complete = "class #{name}\r\n#{code}\r\nend"
      File.open("./generated/#{name}.rb", 'w') { |f| f.write(complete) }
      complete
    else
      temp = c.class_eval(code)
      (temp || c)
    end
  end

  def self.create_context_factory(args, block)
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

  def generate_context_code(default, name)
    if block_given?
      return role_or_interaction_method(:generate_context_code,&b)
    end
    fields = ''
    getters = ''
    impl = ''
    interactions = ''
    @interactions.each do |method_name, method|
      interactions << "  #{method.build_as_context_method method_name, roles, contracts, nil}"
    end
    if default
      interactions << %{
         def self.call(*args)
             arity = #{name}.method(:new).arity
             newArgs = args[0..arity-1]
             obj = #{name}.new *newArgs
             if arity < args.length
                 methodArgs = args[arity..-1]
                 obj.#{default} *methodArgs
             else
                obj.#{default}
             end
         end
         }
      interactions <<"\ndef call(*args);#{default} *args; end\n"
    end

    @roles.each do |role, methods|
      fields << "@#{role}\n"
      getters << "def #{role};@#{role} end\n"
      methods.each do |method_name, method_info|
        rewritten_method_name = "self_#{role}_#{method_name}"
        definition = method_info.build_as_context_method rewritten_method_name, roles, contracts, role

        impl << "  #{definition}" if definition
      end
    end

    "#{interactions}\n#{fields}\n  private\n#{getters}\n#{impl}\n"
  end

  def role_or_interaction_method(method_name,on_self = false, &b)
    raise "method with out block #{method_name}" unless b

    methods[method_name] = MethodInfoCtx.new on_self, &b
  end

  def contracts
    if block_given?
      return role_or_interaction_method(:contracts,&b)
    end
    (@contracts ||= {})
  end

  def role_aliases
    if block_given?
      return role_or_interaction_method(role_aliases,&b)
    end
    @alias_list if @alias_list
    @alias_list = Hash.new
    @role_alias.each { |aliases|
      aliases.each { |k, v|
        @alias_list[k] = v
      }
    }
    @alias_list
  end

  def roles
    if block_given?
      return role_or_interaction_method(:roles,&b)
    end
    @cached_roles_and_alias_list if @cached_roles_and_alias_list
    @roles unless @role_alias and @role_alias.length
    @cached_roles_and_alias_list = Hash.new
    @roles.each { |k, v|
      @cached_roles_and_alias_list[k] = v
    }
    role_aliases.each { |k, v|
      @cached_roles_and_alias_list[k] = @roles[v]
    }
    @cached_roles_and_alias_list
  end

  def add_alias (a, role_name)
    if block_given?
      return role_or_interaction_method(:add_alias,&b)
    end
    @cached_roles_and_alias_list, @alias_list = nil
    @role_alias.last()[a] = role_name
  end

  alias method_missing role_or_interaction_method
end