class MethodInfo
       
def initialize(on_self,block_source,is_private)
    raise("Must be S-Expressions") unless block_source.instance_of?(Sexp)
if on_self.instance_of?(Hash) then
  @block = on_self[:block]
  @on_self = on_self[:self]
else
  @on_self = on_self
end
@block_source = block_source
@private = is_private
self.freeze

 end
 
def is_private()
    @private
 end
 
def build_as_context_method(context_method_name,interpretation_context)
    AstRewritter.new(self_block_source_body, interpretation_context).rewrite!
body = Ruby2Ruby.new.process(self_block_source_body)
args = if self_block_source_arguments then
  (("(" + self_block_source_arguments) + ")")
else
  ""
end
on = on_self ? ("self.") : ("")
(((((("\ndef " + on.to_s) + context_method_name.to_s) + args) + "\n    ") + body) + "\n end\n")

 end

 private
attr_reader :on_self
      attr_reader :block
      attr_reader :block_source
      
       
def self_block_source_get_arguments()
    sexp = block_source[2]
case
when (sexp == nil) then
  nil
when (sexp[0] == :lasgn) then
  sexp[1]
when (sexp[1] == nil) then
  []
else
  (sexp = sexp[(1..-1)]
  args = []
  sexp.each do |e|
    (args << (if e.instance_of?(Symbol) then
      e
    else
      (e[0] == :splat) ? (("*" + e[1][1].to_s)) : (e[1])
    end))
  end
  if block then
    b = ("&" + block.to_s)
    if args then
      args = [args] unless args.instance_of?(Array)
      (args << b)
    else
      args = [b]
    end
  end
  args)
end

 end
   
def self_block_source_arguments()
    args = self_block_source_get_arguments
args and args.length ? (args.join(",")) : (nil)

 end
   
def self_block_source_body()
    block_source[3]
 end

    
      end