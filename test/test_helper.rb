require 'minitest/autorun'
require 'sourcify'
require_relative 'assertions'

# test generated lib
require_relative '../generated/maroon'
require_relative '../generated/maroon/kernel'

# test core lib
# require_relative '../lib/maroon'
# require_relative '../lib/maroon/kernel'

#require 'debugger'
#reuqire 'byebug'

def get_sexp &b
  begin
    b.to_sexp
  rescue
    puts "failed to get expression"
  end

end
