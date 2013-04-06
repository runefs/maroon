require 'ripper'
require 'ruby2ruby'

module SourceAssertions
  def assert_source_equal(expected, actual)

    expected_sexp = if expected.instance_of? Sexp then expected else Ripper::sexp expected end
    actual_sexp =  if actual.instance_of? Sexp then actual else Ripper::sexp actual end
    message = "
Expected: #{expected}
Actual:   #{actual}"
    assert_sexp_with_ident(expected_sexp, actual_sexp, message)
    assert_equal(1,1) #just getting the correct assertion count
  end

  def is_terminal(sexp)
    sexp == :@ident || sexp == :@int || sexp == :@ivar || :@tstring_content
  end

  def assert_sexp_with_ident(expected, actual, message)
    if is_terminal expected[0]
      if expected[-1].instance_of? Array
        if actual[-1].instance_of? Array
          if actual[-1].length == 2
            if expected[-1].length == 2
              return assert_sexp_with_ident(expected[1..-2], actual[1..-2], message)
            end
          end
        end
      end
    end
    if (expected.length - actual.length) ** 2 == 1
      if expected.length < actual.length
        if actual[-1][0] == :arglist && actual[-1].length == 1
          actual = actual[0..-2]
        end
      else
        if expected[i][0] == :arglist  && expected[i].length == 1
          expected = expected[0..-2]
        end
      end
    end

    expected.each_index do |i|
      if expected[i].instance_of? Array or expected[i].instance_of? Sexp
        if actual[i].instance_of? Array or actual[i].instance_of? Sexp
          assert_sexp_with_ident(expected[i], actual[i], message)
        else
          msg = message || "the arrays differ at index #{i}. Actual was an element but an array was expected"
          refute(true,msg)
        end
      else
        if expected[i] != actual[i]
          assert_equal(expected[i],actual[i], message || "the arrays differ at index #{i}")
        end
      end
    end
  end
end