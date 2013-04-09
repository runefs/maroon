class MethodInfo

  def initialize (name, on_self, source, is_private)
    @private = is_private
    raise "Must be Sexp was #{source.class.name}" unless source.instance_of? Sexp
    raise "No body" unless source
    if on_self.instance_of?(Hash) then
      @block = on_self[:block]
      @on_self = on_self[:self]
    else
      @on_self = on_self
    end
    @block_source = source
    @body = @block_source[3]
    @name = name
    self.freeze
  end

  def is_private
    @private
  end

  def build_as_context_method (context_method_name, interpretation_context)
    sexp = @body
    block = MethodDefinition.new(sexp, interpretation_context).transform

    body_as_text = Ruby2Ruby.new.process(block)
    args = self_block_source_arguments ? ("(#{self_block_source_arguments})") : (nil)
    on = on_self ? ("self.") : ("")
    "\ndef #{on}#{context_method_name}#{args}\n#{body_as_text} end\n"
  end

  attr_reader :name

  private
  attr_reader :on_self
  attr_reader :block
  attr_reader :block_source
  attr_reader :body


  def self_block_source_get_arguments
    sexp = block_source[2]
    return nil unless sexp
    return sexp[1] if (sexp[0] == :lasgn)
    return [] if sexp[1] == nil
    sexp = sexp[(1..-1)]
    args = []
    sexp.each { |e|
      arg = (e.instance_of? Symbol) ? e : if e[0] == :splat then
                                            "*#{e[1][1]}"
                                          else
                                            e[1]
                                          end
      args[args.length] = arg
    }
    if block
      b = "&#{block}"
      if args
        args[args.length] = b
      else
        args = [b]
      end
    end
    args
  end

  def self_block_source_arguments
    args = self_block_source_get_arguments

    if args.instance_of? Array
      if args.length == 1
        args[0]
      else
        args.join(',')
      end
    else
      args
    end
  end

  def self_block_source_body
    body
  end


  def self.assert_that(obj)
    ContextAsserter.new(self.contracts, obj)
  end

  def self.refute_that(obj)
    ContextAsserter.new(self.contracts, obj, false)
  end

  def self.contracts
    @@contracts
  end

  def self.contracts=(value)
    raise 'Contracts must be supplied' unless value
    @@contracts = value
  end

end