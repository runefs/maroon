context :Self, :execute do
  initialize do |abstract_syntax_tree, interpretationcontext|
    raise "Interpretation context missing" unless interpretationcontext
    raise "Must have a defining role" unless interpretationcontext.defining_role

    @abstract_syntax_tree = abstract_syntax_tree
    @interpretation_context = interpretationcontext
  end

  role :abstract_syntax_tree do
    is_indexer_call_on_self do
      abstract_syntax_tree.length == 4 &&
      abstract_syntax_tree[0] == :call &&
      abstract_syntax_tree[1] == nil &&
      abstract_syntax_tree[2] == :[] &&
      abstract_syntax_tree[3][0] == :argslist
    end

  end
  role :interpretation_context do
    defining_role do
      interpretation_context.defining_role
    end
  end

  # rewrites a call to self in a role method to a call to the role player accessor
  # which is subsequently rewritten to a call to the instance variable itself
  # in the case where no role method is called on the role player
  # It's rewritten to an instance call on the context object if a role method is called
  execute do
    if abstract_syntax_tree
      if abstract_syntax_tree[0] == :self #if self is used in a role method, then rewrite to role getter
        abstract_syntax_tree[0] = :call
        abstract_syntax_tree[1] = nil
        abstract_syntax_tree[2] = interpretation_context.defining_role
        arglist = Sexp.new
        abstract_syntax_tree[3] = arglist
        arglist[0] = :arglist
      elsif abstract_syntax_tree[0] == :call and abstract_syntax_tree[1] == nil
          method_name = abstract_syntax_tree[2]
          #self is removed from S-expressions
          if method_name == :[] or method_name == :[]=
            get_role = Sexp.new
            get_role[0] = :call
            get_role[1] = nil
            get_role[2] = interpretation_context.defining_role
            arglist = Sexp.new
            get_role[3] = arglist
            arglist[0] = :arglist
            abstract_syntax_tree[1] = get_role
          end
      elsif abstract_syntax_tree.instance_of? Sexp
        if abstract_syntax_tree.is_indexer_call_on_self
          getter = new Sexp.new
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
end