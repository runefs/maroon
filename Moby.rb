require 'live_ast'
require 'live_ast/to_ruby'

class Context
  #meta programming
  @@roles = Hash.new
  @@interactions = Hash.new
  @@defining_role
  #meta end

  def Context.finalize
    code = "def this;self end\n"
    @@roles.each do |role, methods|
      code += "@#{role}\ndef #{role};@#{role};end\nprivate :#{role}\n" #never used but class_eval will complain if not declared
      methods.each do |method_name, method_source|
        name = "self_#{role}_#{method_name}"
        source = lambda2method(name, method_source)
        code += "#{source}\nprivate :#{name}\n"
      end
    end
    @@interactions.each do |name, method_source|
      code += lambda2method name, method_source
    end
    #File.open("generate.rb", 'w') { |f| f.write(code) }
    class_eval(code)
  end

  def self.lambda2method (method_name, method_source)
    ast = (ast_eval method_source, binding).to_ast
    transform_ast ast
    args, block = block2source LiveAST.parser::Unparser.unparse(ast)
    "\ndef #{method_name} #{args} \n#{block}\n end\n"
  end

  def Context.role(role_name)
    @@defining_role = role_name
    (@@roles ||= Hash.new)[role_name] = Hash.new
    yield if block_given?
  end

  def Context.transform_ast(ast)
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

  def Context.role_method_call(ast, method)
    is_call_expression = ast && ast[0] == :call
    self_is_instance_expression = is_call_expression && (!ast[1] || ast[1] == :self) #implicit or explicit self
    is_role = self_is_instance_expression && (role = @@roles[ast[2]]) #is it a call to a role getter
    is_role_method = is_role && role.has_key?(method)
    ast[2] if is_role_method #return role name
  end

  def self.block2source(b)
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

  def Context.role_method(method_name, &b)
    args, block = block2source b.to_ruby
    @@roles[@@defining_role][method_name] = "lambda {|#{args}| #{block}}"
  end

  def Context.interaction(method_name, &b)
    args, block = block2source b.to_ruby
    (@@interactions ||= Hash.new)[method_name] = "lambda {|#{args}| #{block}}"
  end
end