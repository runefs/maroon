# -*- encoding: utf-8 -*-
require 'live_ast'
require 'live_ast/to_ruby'

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
class Context
  @roles
  @interactions
  @defining_role
  @role_alias
  @alias_list
  @cached_roles_and_alias_list

  #define is the only exposed method and can be used to define a context (class)
  #if maroon/kernel is required calling context of Context::define are equivalent
  #params
  #name:: the name of the context. Since this is used as the name of a class, class naming convetions should be used
  #block:: the body of the context. Can include definitions of roles (through the role method) or definitions of interactions
  #by simply calling a method with the name of the interaction and passing a block as the body of the interaction
  def self.define(*args, &block)
    name,base_class,default_interaction = *args
    #if there's two arguments and the second is not a class it must be an interaction
    base_class,default_interaction = default_interaction, base_class if base_class and !default_interaction and base_class.instance_of? Symbol
    ctx = Context.new
    ctx.instance_eval &block
    return ctx.send(:finalize, name,base_class,default_interaction)
  end

  private
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
    @roles = Hash.new
    @interactions = Hash.new
    @role_alias = Array.new
  end

  def role_aliases
    @alias_list if @alias_list
    @alias_list = Hash.new
    @role_alias.each {|aliases|
      aliases.each {|k,v|
        @alias_list[k] = v
      }
    }
    @alias_list
  end

  def roles
    @cached_roles_and_alias_list if @cached_roles_and_alias_list
    @roles unless @role_alias and @role_alias.length
    @cached_roles_and_alias_list = Hash.new
    @roles.each {|k,v|
       @cached_roles_and_alias_list[k] = v
    }
    role_aliases.each {|k,v|
      @cached_roles_and_alias_list[k] = @roles[v]
    }
    @cached_roles_and_alias_list
  end

  def methods
    (@defining_role ? @roles[@defining_role] : @interactions)
  end

  def add_alias (a,role_name)
    @cached_roles_and_alias_list,@alias_list = nil
    @role_alias.last()[a] = role_name
  end

  def finalize(name, base_class, default)
    c = base_class ? (Class.new base_class) : Class.new
    Kernel.const_set name, c
    code = ''
    fields = ''
    getters = ''
    impl = ''
    interactions = ''
    @interactions.each do |method_name, method_source|
      @defining_role = nil
      interactions << "  #{lambda2method(method_name, method_source)}"
    end
    if default
      interactions <<"\ndef self.execute(*args);#{name}.new(*args).#{default}; end\n"
    end

    @roles.each do |role, methods|
        fields << "@#{role}\n"
        getters << "def #{role};@#{role} end\n"

        methods.each do |method_name, method_source|
          @defining_role = role
          rewritten_method_name = "self_#{role}_#{method_name}"
          definition = lambda2method rewritten_method_name, method_source
          impl << "  #{definition}" if definition
        end
    end

    code << "#{interactions}\n#{fields}\n  private\n#{getters}\n#{impl}\n"

    complete = "class #{name}\r\n#{code}\r\nend"
    temp = c.class_eval(code)
    return (temp ||c),complete
  end

  def role_or_interaction_method(method_name,*args, &b)
    raise "method with out block #{method_name}" unless b

    args, block = block2source b.to_ruby, method_name
    args = "|#{args}|" if args
    source = "(proc do #{args}\n #{block}\nend)"
    methods[method_name] = source
  end

  alias method_missing role_or_interaction_method

  def role_method_call(ast, method)
    is_call_expression = ast && ast[0] == :call
    self_is_instance_expression = is_call_expression && (!ast[1]) #implicit self
    is_in_block = ast && ast[0] == :lvar
    role_name_index = self_is_instance_expression ? 2 : 1
    role = (self_is_instance_expression || is_in_block) ? roles[ast[role_name_index]] : nil #is it a call to a role getter
    is_role_method = role && role.has_key?(method)
    role_name = is_in_block ? role_aliases[ast[1]] : (ast[2] if self_is_instance_expression)
    role_name if is_role_method #return role name
  end

  def lambda2method (method_name, method_source)
    evaluated = ast_eval method_source, binding
    ast = evaluated.to_ast
    transform_ast ast
    args, block = block2source LiveAST.parser::Unparser.unparse(ast), method_name
    args = "(#{args})" if args
    "\ndef #{method_name} #{args}\n#{block} end\n"
  end

  ##
  #Test if there's a block that needs to potentially be transformed
  ##
  def transform_block(exp)
       if exp && exp[0] == :iter
           (exp.length-1).times do |i|
             expr = exp[i+1]
             #find the block
             if expr  && expr.length && expr[0] == :block
               transform_ast exp if rewrite_bind? expr,expr[1]
             end
           end
       end
  end

  ##
  #Calls rewrite_block if needed and will return true if the AST was changed otherwise false
  ##
  def rewrite_bind?(block, expr)
    #check if the first call is a bind call
    if expr && expr.length && (expr[0] == :call && expr[1] == nil && expr[2] == :bind)
      arglist = expr[3]
      if arglist && arglist[0] == :arglist
        arguments = arglist[1]
        if arguments && arguments[0] == :hash
          block.delete_at 1
          count = (arguments.length-1) / 2
          (1..count).each do |j|
            temp = j * 2
            local = arguments[temp-1][1]
            if local.instance_of? Sexp
              local = local[1]
            end
            raise 'invalid value for role alias' unless local.instance_of? Symbol
            #find the name of the role being bound to
            aliased_role = arguments[temp][1]
            if aliased_role.instance_of? Sexp
              aliased_role = aliased_role[1]
            end
            raise "#{aliased_role} used in binding is an unknown role #{roles}" unless aliased_role.instance_of? Symbol and @roles.has_key? aliased_role
            add_alias local, aliased_role
            #replace bind call with assignment of iteration variable to role field
            rewrite_bind(aliased_role, local, block)
            return true
          end
        end
      end
    end
    false
  end

  ##
  #removes call to bind in a block
  #and replaces it with assignment to the proper role player local variables
  #in the end of the block the local variables have their original values reassigned
  def rewrite_bind(aliased_role, local, block)
    raise 'aliased_role must be a Symbol' unless aliased_role.instance_of? Symbol
    raise 'local must be a Symbol' unless local.instance_of? Symbol
    aliased_field = "@#{aliased_role}".to_sym
    assignment = Sexp.new
    assignment[0] = :iasgn
    assignment[1] = aliased_field
    load_arg = Sexp.new
    load_arg[0] = :lvar
    load_arg[1] = local
    assignment[2] = load_arg
    block.insert 1, assignment

    # assign role player to temp
    temp_symbol = "temp____#{aliased_role}".to_sym
    assignment = Sexp.new
    assignment[0] = :lasgn
    assignment[1] = temp_symbol
    load_field = Sexp.new
    load_field[0] = :ivar
    load_field[1] = aliased_field
    assignment[2] = load_field
    block.insert 1, assignment

    # reassign original player
    assignment = Sexp.new
    assignment[0] = :iasgn
    assignment[1] = aliased_field
    load_temp = Sexp.new
    load_temp[0] = :lvar
    load_temp[1] = temp_symbol
    assignment[2] = load_temp
    block[block.length] = assignment
  end

  # rewrites a call to self in a role method to a call to the role player accessor
  # which is subsequently rewritten to a call to the instance variable itself
  # in the case where no role method is called on the role player
  # It's rewritten to an instance call on the context object if a role method is called
  def rewrite_self (ast)
    ast.length.times do |i|
      raise 'Invalid argument. must be an expression' unless ast.instance_of? Sexp
      exp = ast[i]
      if exp == :self
        ast[0] = :call
        ast[1] = nil
        ast[2] = @defining_role
        arglist = Sexp.new
        ast[3] = arglist
        arglist[0] = :arglist
      elsif exp.instance_of? Sexp
        rewrite_self exp
      end
    end
  end

  #rewrites the ast so that role method calls are rewritten to a method invocation on the context object rather than the role player
  #also does rewriting of binds in blocks
  def transform_ast(ast)
    if ast
      if @defining_role
        rewrite_self ast
      end
      ast.length.times do |k|
        exp = ast[k]
        if exp
          method_name = exp[2]
          role = role_method_call exp[1], exp[2]
          if exp[0] == :iter
            @role_alias.push Hash.new
            transform_block exp
            @role_alias.pop()
          end
          if exp[0] == :call && role
            exp[1] = nil #remove call to attribute
            exp[2] = "self_#{role}_#{method_name}".to_sym
          end
          if exp.instance_of? Sexp
            transform_ast exp
          end
        end
      end
    end
  end

  #cleans up the string for further processing and separates arguments from body
  def block2source(b, method_name)
    args = nil
    block = b.strip
    block = block[method_name.length..-1].strip if block.start_with? method_name.to_s
    block = cleanup_head_and_tail(block)
    if block.start_with? '|'
      args = block.scan(/\|([\w\d,\s]*)\|/)
      if args.length && args[0]
        args = args[0][0]
      else
        args = nil
      end
      block = block[(2 + (block[1..-1].index '|'))..-1].strip
    end
    return args, block
  end

  # removes proc do/{ at start and } or end at the end of the string
  def cleanup_head_and_tail(block)
    if /^proc\s/.match(block)
      block = block['proc'.length..-1].strip
    end
    if /^do\s/.match(block)
      block = block[2..-1].strip
    elsif block.start_with? '{'
      block = block[1..-1].strip
    end

    if /end$/.match(block)
      block = block[0..-4]
    elsif /\}$/.match(block)
      block = block[0..-2]
    end
    block
  end
end