if Kernel::const_defined? :MiniTest
  class ContextAsserterBase < MiniTest::Unit::TestCase

  end
else
  class ContextAsserterBase

  end
end

class ContextAsserter < ContextAsserterBase
  def initialize(contracts, obj, is_asserting = true)
    raise 'Contracts must be supplied' unless contracts
    @obj = obj
    @contracts = contracts
    @is_asserting = is_asserting
  end

  def is_test
    Kernel::const_defined? :MiniTest
  end

  def can_play(role)
    msg = "#{@is_asserting ? 'Was' : "wasn't"} expected to be able to play #{role}".intern
    if is_test
      assert_equal(@is_asserting, can_play?(role), msg)
    else
      raise msg if @is_asserting != can_play?(role)
    end

  end

  private
  def can_play?(role)
    required_methods = @contracts[role]
    return true if !(required_methods && required_methods.length)

    methods = @obj.public_methods
    missing = required_methods.select do |rm|
      !methods.include? rm.to_sym
    end
    missing.length == 0
  end
end
Context::with_contracts(true)