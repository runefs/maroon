class Self
  
def initialize (abstract_syntax_tree,interpretationcontext)
raise("Interpretation context missing") unless interpretationcontext
unless interpretationcontext.defining_role then
  raise("Must have a defining role")
end
@abstract_syntax_tree = abstract_syntax_tree
@interpretation_context = interpretationcontext
 end
  
def execute 
if abstract_syntax_tree then
  if (abstract_syntax_tree[0] == :self) then
    abstract_syntax_tree[0] = :call
    abstract_syntax_tree[1] = nil
    abstract_syntax_tree[2] = interpretation_context.defining_role
    arglist = Sexp.new
    abstract_syntax_tree[3] = arglist
    arglist[0] = :arglist
  else
    if (abstract_syntax_tree[0] == :call) and (abstract_syntax_tree[1] == nil) then
      method_name = abstract_syntax_tree[2]
      if ((method_name == :[]) or (method_name == :[]=)) then
        get_role = Sexp.new
        get_role[0] = :call
        get_role[1] = nil
        get_role[2] = interpretation_context.defining_role
        arglist = Sexp.new
        get_role[3] = arglist
        arglist[0] = :arglist
        abstract_syntax_tree[1] = get_role
      end
    else
      if abstract_syntax_tree.instance_of?(Sexp) then
        if self_abstract_syntax_tree_is_indexer_call_on_self then
          getter = new(Sexp.new)
          getter[0] = :call
          getter[1] = nil
          getter[2] = interpretation_context.defining_role
          arglist = Sexp.new
          getter[3] = arglist
          arglist[0] = :arglist
          abstract_syntax_tree[1] = getter
        end
      end
    end
  end
end end

         def self.call(*args)
             arity = Self.method(:new).arity
             newArgs = args[0..arity-1]
             obj = Self.new *newArgs
             if arity < args.length
                 methodArgs = args[arity..-1]
                 obj.execute *methodArgs
             else
                obj.execute
             end
         end
         
def call(*args);execute *args; end

  private
attr_reader :abstract_syntax_tree
attr_reader :interpretation_context

  
def self_abstract_syntax_tree_is_indexer_call_on_self 
(abstract_syntax_tree.length == 4) and ((abstract_syntax_tree[0] == :call) and ((abstract_syntax_tree[1] == nil) and ((abstract_syntax_tree[2] == :[]) and (abstract_syntax_tree[3][0] == :argslist)))) end


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