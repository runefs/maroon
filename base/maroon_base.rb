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
#    Context.define :Greeter do
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
    name, base_class, default_interaction = *args

    if default_interaction and (not base_class.instance_of?(Class)) then
      base_class = eval(base_class.to_s)
    end
    if base_class and ((not default_interaction) and (not base_class.instance_of?(Class))) then
      base_class, default_interaction = default_interaction, base_class
    end
    @with_contracts ||= nil

    ctx = self.send(:create_context_factory, name, base_class, default_interaction, block)

    if self.generate_dependency_graph
      dependencies = {}
      ctx.dependencies = DependencyGraphModel.new(DependencyGraph.new(name,ctx.methods,dependencies).create!)
    end
    transformer = Transformer.new(name, ctx.methods, ctx.private_interactions, base_class, default_interaction)
    ctx.generated_class = transformer.transform(generate_files_in, @with_contracts)
    ctx
  end

  def self.generate_files_in
    @generate_files_in
  end

  def self.generate_files_in=(folder)
    @generate_files_in = folder
  end

  def self.generate_code=(value)
    @generate_code = value
  end

  def self.generate_dependency_graph=(value)
    @generate_dependency_graph = value
  end

  def self.generate_code
    @generate_code || !generate_dependency_graph || generate_files_in
  end

  def self.generate_dependency_graph
    @generate_dependency_graph
  end

  def dependencies
    @dependencies
  end

  def generated_class
    @generated_class
  end

  def dependencies=(value)
    @dependencies=value
  end
  def generated_class=(value)
    @generated_class=value
  end

  def methods
    @methods ||= {}
  end

  def private_interactions
    @private_interactions
  end


  private
  def get_sexp(b)
    begin
      b.to_sexp
    rescue NoMethodError => e
      if e.message == 'undefined method `[]\' for nil:NilClass'
        raise 'It would seem you used a double quote somewhere which is unfortunately not supported'
      else
        raise e
      end
    end
  end
  def get_definitions(b)
    sexp = get_sexp b

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

  def self.create_context_factory(name, base_class, default_interaction, block)

    ctx = Context.new name, base_class, default_interaction
    ctx.instance_eval {
      file,_ = block.source_location
      sexp = get_sexp block
      temp_block = sexp[3]
      i = 0
      raise 'Could not parse \'' + name.to_s + '\' try using \'{|| }\' for the context block and \'do\'...\'end\' for the roles'  unless temp_block
      while i < temp_block.length
        exp = temp_block[i]
        # conditions changed due to updated format of sexp_processor gem used at sourcify 0.6.0
        # unless temp_block[i-2] && temp_block[i-2][0] == :call && temp_block[i-1] && temp_block[i-1][0] == :args
        unless temp_block[i-2] && temp_block[i-2][0] == :call && temp_block[i-2][3][0] == :arglist
          if exp && (exp[0] == :defn || exp[0] == :defs)
            add_method(exp,nil,file)
            temp_block.delete_at i
            i -= 1
          elsif exp && (exp[0] == :call && exp[1] == nil && exp[2] == :private)
            @private = true
          end
        end
        i += 1
      end
      ctx.instance_eval &block
    }

    ctx
  end

  def self.with_contracts(*args)
    return @with_contracts if (args.length == 0)
    value = args[0]
    if @with_contracts and (not value) then
      raise('make up your mind! disabling contracts during execution will result in undefined behavior')
    end
    @with_contracts = value

  end

  def is_definition?(exp)
    exp && (exp[0] == :defn || exp[0] == :defs)
  end

  def role(role_name, &b)
    file_name,line_no = b.source_location

    @defining_role = Role.new(role_name, line_no, file_name)
    methods[role_name] ||= @defining_role
    if block_given? then
      definitions = get_definitions(b)
      file,line = b.source_location
      definitions.each { |exp| add_method(exp,nil , file) }
    end
  end

  def add_method(definition,line_no, file_name)
    name = if definition[1].instance_of? Symbol
             definition[1]
           else
             (definition[1].select { |e| e.instance_of? Symbol }.map { |e| e.to_s }.join('.') + '.' + definition[2].to_s).to_sym
           end

    key = @defining_role == nil ? nil : @defining_role.name
    unless @methods.has_key?(key) then
      if (@defining_role == nil) then
        @methods[key] = Role.new(nil, line_no, file_name)
      else
        raise 'Undefined role ' + @defining_role.name.to_s
      end
    end
    @methods[key].methods[name] = definition
    if @defining_role == nil && @private
      @private_interactions[name] = true
    end
  end

  def private
    @private = true
  end

  def initialize(name,base_class,default_interaction)
    @methods = {}
    @private_interactions = {}
    @role_alias = {}
    @name = name
    @base_class = base_class
    @default_interaction = default_interaction
  end

  role :name do end
  role :base_class do end
  role :default_interaction do end

end

context_class_code = c.generated_class

if context_class_code.instance_of? String
  file_name = './generated/context.rb'
  p "writing to: " + file_name
  File.open(file_name, 'w') do |f|
    f.write(context_class_code)
  end
end
