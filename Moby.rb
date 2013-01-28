require 'live_ast'
require 'live_ast/to_ruby'

class Context
  #meta programming
  @roles
  @interactions
  @defining_role
  #meta end

  def initialize
    @roles = Hash.new
    @interactions = Hash.new
  end

  def self.define(name, &block)
    ctx = Context.new
    ctx.instance_eval &block
    ctx.finalize name
  end

  def finalize(name)
    c = Class.new
    Kernel.const_set name, c
    code = ""
    fields = ""
    getters = ""
    impl = ""
    initializer = ""
    initializer_head = "  def initialize ( "
    interactions = ""
    @interactions.each do |method_name, method_source|
      interactions << "  #{lambda2method(method_name, method_source)}"
    end
    @roles.each do |role, methods|
      fields << "@#{role}\n"
      getters << "def #{role};@#{role} end\n"
      initializer << "    @#{role} = #{role}\n"
      initializer_head << "#{role},"
      methods.each do |method_name, method_source|
        name = "self_#{role}_#{method_name}"
        definition = lambda2method name, method_source
        impl << "  #{definition}" if definition
      end
    end

    code << "#{interactions}\n#{fields}\n#{initializer_head[0..-2]})\n#{initializer}  end\n  private\n#{getters}\n#{impl}\n"

    #File.open("generate.rb", 'w') { |f| f.write(code) }
    c.class_eval(code)
  end

  def role(role_name)
    @defining_role = role_name
    @roles[role_name] = Hash.new
    yield if block_given?
    @defining_role = nil
  end

  def methods
    (@defining_role ? @roles[@defining_role] : @interactions)
  end

  def role_or_interaction_method(method_name, &b)
    args, block = block2source b.to_ruby
    source = "lambda {|#{args}| #{block}}"
    methods[method_name] = source
  end

  alias method_missing role_or_interaction_method

  def role_method_call(ast, method)
    is_call_expression = ast && ast[0] == :call
    self_is_instance_expression = is_call_expression && (!ast[1] || ast[1] == :self) #implicit or explicit self
    role = self_is_instance_expression ? @roles[ast[2]] : nil #is it a call to a role getter
    is_role_method = role && role.has_key?(method)
    ast[2] if is_role_method #return role name
  end

  def lambda2method (method_name, method_source)
    ast = (ast_eval method_source, binding).to_ast
    transform_ast ast
    args, block = block2source LiveAST.parser::Unparser.unparse(ast)
    "\n  def #{method_name} (#{args})#{block}  end\n"
  end

  def transform_ast(ast)
    if ast
      ast.each do |exp|
        if exp
          method_name = exp[2]
          role = role_method_call exp[1], exp[2]
          if exp[0] == :call && role
            exp[1] = nil #remove call to attribute
            exp[2] = "self_#{role}_#{method_name}".to_sym
          elsif exp.instance_of? Sexp
            transform_ast exp
          end
        end
      end
    end
  end

  def block2source(b)
    block = b.strip
    index = (block.index '|') + 1
    index = 0 if index < 0
    block = block[index..-1]
    index = (block.index '|') - 1
    index = -1 if index < 0
    args = block[0..index]
    if /end$/.match(block)
      block = block[(index+2)..-4]
    elsif /\}$/.match(block)
      block = block[(index+2)..-2]
    end
    return args, block
  end
end