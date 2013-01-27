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
      code += "@#{role}\nattr_reader :#{role}\n"
      methods.each do |method_name, method_source|
        ast = (ast_eval method_source, binding).to_ast
        transform_ast ast
        args, block = block2source LiveAST.parser::Unparser.unparse(ast)
        name = "self_#{role}_#{method_name}";
        code += "\ndef #{name} (#{args}) \n#{block}\n end\nprivate :#{name}\n"
      end
    end
    @@interactions.each do |name, method_source|
      ast = (ast_eval method_source, binding).to_ast
      transform_ast ast
      args, block = block2source LiveAST.parser::Unparser.unparse(ast)
      code += "\ndef #{name} #{args} \n#{block}\n end\n"
    end
    class_eval(code)
    File.open("generate.rb", 'w') { |f| f.write(code) }
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
            exp[1] = nil
            exp[2] = "self_#{role}_#{method_name}".to_sym
          elsif exp.instance_of? Sexp
            transform_ast exp
          end
        end
      end
    end
  end

  def Context.role_method_call(ast, method)
    is_role = ast && ast[0] == :call && ((!ast[1] || ast[1] == :self) && @@roles.has_key?(ast[2]))
    ast[2] if is_role && @@roles[ast[2]].has_key?(method)
  end

  def Context.block2method(method_name, post_code, b)
    name = method_name.to_s
    code = "\r\n"
    args = ""
    if block_given?
      args, block = block2source b
      ast = (ast_eval "lambda {|#{args}| #{block}}", binding).to_ast
      transform_ast ast
      args, block = block2source LiveAST.parser::Unparser.unparse(ast)
    else
      block = ""
    end

    code += "\r\ndef #{name} #{args} \r\n#{block}\r\n end\r\n"
    code += post_code.join("#{args}")
    code
  end

  def self.block2source(b)
    block = b
    block.strip!
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