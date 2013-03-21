require 'sourcify'
require 'sorcerer'
require_relative 'helper'

context :MethodInfoCtx do
  initialize do |on_self,block_source|
    if on_self.instance_of? Hash
      @block = on_self[:block]
      @on_self = on_self[:self]
    else
      @on_self = on_self
    end
    @block_source = block_source
    self.freeze
  end

  role :on_self do end
  role :block do end

  role :block_source do
    get_arguments do
      sexp = block_source[2]
      return nil unless sexp
      return sexp[1] if sexp[0] == :lasgn
      sexp = sexp[1][1..-1] # array of arguments
      args = []
      sexp.each { |e|
        args << (if e[0] == :splat then "*#{e[1][1]}" else e[1] end)
      }
      if block
        b = "&#{block}"
        if args
          args << b
        else
          args = [b]
        end
      end
      args
    end
    arguments do
      args = block_source.get_arguments
      args && args.length ? args.join(',') : nil
    end
    body do
      block_source[3]
    end
  end

  build_as_context_method do |context_method_name, interpretation_context|
    MethodDefinition.new(block_source.body,interpretation_context).transform
    body = Ruby2Ruby.new.process(block_source.body)
    args = block_source.arguments ? "(#{block_source.arguments})" : nil
    on = if on_self then "self." else "" end
    "\ndef #{on}#{context_method_name}#{args}\n#{body} end\n"
  end
end