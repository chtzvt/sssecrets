# frozen_string_literal: true

require "test_helper"

class TestSssecrets < Minitest::Test
  def test_sssecrets_validation
    test = SimpleStructuredSecrets.new("t", "k")
    assert test

    assert test.validate("tk_GUkLdIZV8xnQQZobkuynSyyPkcweVm14nosQ")
    assert test.validate("tk_dNvFPOO3rBGdgEzd7MAWrDZuJsOeur4DlKeW")
    assert test.validate("tk_9vWYJ47Cd2i2gL0afBqdPOdQlqqTno2pP0Jh")
  end

  def test_sssecrets_generation
    test = SimpleStructuredSecrets.new("t", "k")
    assert test

    100_000.times do
      assert test.validate(test.generate)
    end
  end

  def test_sssecrets_headers
    test = SimpleStructuredSecrets.new("t", "k")
    assert test

    prefix = test.generate_header("5be426ee126b88f9587bbbe767a7592c")
    assert test.validate_header(prefix)
  end
end
