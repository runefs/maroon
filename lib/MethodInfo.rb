class MethodInfo
  
def initialize (on_self,block_source)
raise "Must be S-Expressions" unless block_source.instance_of? Sexp
raise "No body" unless block_source
if on_self.instance_of?(Hash) then
  @block = on_self[:block]
  @on_self = on_self[:self]
else
  @on_self = on_self
end
@block_source = block_source
self.freeze
 end
  
def build_as_context_method (context_method_name,interpretation_context)
MethodDefinition.new(self_block_source_body, interpretation_context).transform
block = self_block_source_body
body = Ruby2Ruby.new.process(block)
args = self_block_source_arguments ? ("(#{self_block_source_arguments})") : (nil)
on = on_self ? ("self.") : ("")
"\ndef #{on}#{context_method_name}#{args}\n#{body} end\n"
 end

  private
attr_reader :on_self
attr_reader :block
attr_reader :block_source

  
def self_block_source_get_arguments 
sexp = block_source[2]
return nil unless sexp
return sexp[1] if (sexp[0] == :lasgn)
return [] if sexp[1] == nil
sexp = sexp[(1..-1)]
args = []
sexp.each { |e|
  (args << ((e.instance_of? Symbol) ? e : (if e[0] == :splat then "*#{e[1][1]}" else e[1] end)))
}
if block then
  b = "&#{block}"
  args ? ((args << b)) : (args = [b])
end
args
 end
  
def self_block_source_arguments 
args = self_block_source_get_arguments
args and args.length ? (args.join(",")) : (nil)
 end
  
def self_block_source_body 
block_source[3] end


        def self.assert_that(obj)
          ContextAsserter.new(self.contracts,obj)
        end
        def self.refute_that(obj)
          ContextAsserter.new(self.contracts,obj,false)
        end
        def self.contracts
          @@contracts
        end
        def self.contracts=(value)
          raise 'Contracts must be supplied' unless value
          @@contracts = value
        end

end