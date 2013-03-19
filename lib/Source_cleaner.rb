require 'sourcify'
require 'sorcerer'

module SourceCleaner
  private
  #Separates arguments from body
  def block2source(&block)
    source = block.to_sexp
    raise 'unknown format' unless source[0] == :iter or source.length != 4
    args = get_args source[2]
    body = source[3]
    return args, body
  end

  #Gets argument names as a comma separated list
  def get_args(sexp)
    return nil unless sexp
    return sexp[1] if sexp[0] == :lasgn
    sexp = sexp[1][1..-1] # array or arguments
    args = []
    sexp.each { |e|
      args << e[1]
    }
    args.join(',')
  end

  #Transforms a S-expression body to source
  def method_info2method_definition (method_name, method)
    arguments, body = method.arguments, method.body
    transform_ast body
    block = Ruby2Ruby.new.process(body)
    args = "(#{arguments})" if arguments
    on = if method.on_self then "self." else "" end
    "\ndef #{on}#{method_name} #{args}\n#{block} end\n"
  end
end
