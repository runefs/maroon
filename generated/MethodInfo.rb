class MethodInfo
       
def initialize(name, args, body,is_private)
    raise("Must be S-Expressions") unless body.instance_of?(Sexp)

@body = body
@private = is_private
    @args = args
    @name = name
self.freeze

 end
 
def is_private()
    @private
 end
 
def build_as_context_method(interpretation_context)
    AstRewritter.new(@body, interpretation_context).rewrite!
    body = Ruby2Ruby.new.process(@body)
    arguments = @args && @args.length ? ('('+ @args.join(",") + ')') : ''
    on = on_self ? ("self.") : ("")
((((("\ndef " + @name.to_s) + arguments) + "\n    ") + body) + "\n end\n")

 end
end