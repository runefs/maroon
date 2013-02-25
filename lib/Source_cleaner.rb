require 'live_ast'
require 'live_ast/to_ruby'

module Source_cleaner
 private
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
  #cleans up the string for further processing and separates arguments from body
  def block2source(method_name, &block)
    source = block.to_ruby
    return get_args_and_body(method_name,source)
  end

 def get_args_and_body(method_name, source)
   args = nil
   block = source.strip
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

 def lambda2method (method_name, method_source)
    evaluated = ast_eval method_source, binding
    ast = evaluated.to_ast
    transform_ast ast
    args, block = get_args_and_body method_name, LiveAST.parser::Unparser.unparse(ast)
    args = "(#{args})" if args
    "\ndef #{method_name} #{args}\n#{block} end\n"
 end
end
