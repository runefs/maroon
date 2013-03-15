require 'ripper'
require_relative 'helper'
require_relative 'bind_rewriter'
require_relative 'expression_rewriter'
require_relative 'self'

context :MethodDefinition, :transform do
  initialize do |abstract_syntax_tree, defining_role|
    @abstract_syntax_tree = abstract_syntax_tree
    @defining_role = defining_role
  end

  role :abstract_syntax_tree do
  end
  role :defining_role do
  end

  #rewrites the ast so that role method calls are rewritten to a method invocation on the context object rather than the role player
  #also does rewriting of binds in blocks
  transform do |roles,contracts|
    if abstract_syntax_tree.instance_of? Sexp
      if defining_role
        Self.rewrite abstract_syntax_tree, defining_role
      end
      Expression.rewrite abstract_syntax_tree,roles,contracts
      abstract_syntax_tree.each do |exp|
        Expression.rewrite exp,roles,contracts if exp
      end
    end
  end
end

