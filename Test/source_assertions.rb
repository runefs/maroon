require 'ripper'

module SourceAssertions
  def assert_source_equal(expected, actual)
    expected_sexp = Ripper::sexp expected
    actual_sexp = Ripper::sexp actual
    assert_sexp_with_ident(expected_sexp, actual_sexp, "Expected #{expected} but got #{actual}")
    assert_equal(1,1) #just getting the correct assertion count
  end

  def is_terminal(sexp)
    sexp == :@ident || sexp == :@int || sexp == :@ivar
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

    expected.each_index do |i|
      if expected[i].instance_of? Array
        if actual[i].instance_of? Array
          assert_sexp_with_ident(expected[i], actual[i], message)
        else
          assert_fail(message || "the arrays differ at index #{i}. Actual was an element but an array was expected")
        end
      else
        if expected[i] != actual[i]
          assert_fail (message || "the arrays differ at index #{i}")
        end
      end
    end
  end
end