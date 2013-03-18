require 'sourcify'
require 'sorcerer'
require_relative 'helper'

context :MethodInfoCtx do
  initialize do |block_source|
    @block_source = block_source
  end

  role :block_source do
    get_arguments do
      sexp = block_source[2]
      return nil unless sexp
      return sexp[1] if sexp[0] == :lasgn
      sexp = sexp[1][1..-1] # array of arguments
      args = []
      sexp.each { |e|
        args << e[1]
      }
      args.join(',')
    end
    arguments do
      return @args if @args
      @args = block_source.get_arguments
    end
    body do
      return @body if @body
      @body = block_source[3]
    end
  end

  build_as_context_method do |context_method_name, interpretation_context|
    MethodDefinition.new(block_source.body,interpretation_context).transform
    block = Ruby2Ruby.new.process(block_source.body)
    args = block_source.arguments ? "(#{block_source.arguments})" : nil
    "\ndef #{context_method_name}#{args}\n#{block} end\n"
  end
end