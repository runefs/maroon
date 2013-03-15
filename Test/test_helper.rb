require 'minitest/autorun'
require 'sourcify'
require_relative 'assertions'
require_relative '../generated/interpretation_context'
#require 'debugger'

def get_sexp &b
  b.to_sexp
end
