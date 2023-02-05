# frozen_string_literal: true

# Based on https://github.com/steventen/base62-rb, with light modifications
module Base62
  KEYS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
  KEYS_HASH = KEYS.each_char.with_index.each_with_object({}) do |(k, v), h|
    h[k] = v
  end
  BASE = KEYS.length

  # Encodes base10 (decimal) number to base62 string.
  def base62_encode(num)
    return "0" if num.zero?
    return nil if num.negative?

    str = ""
    while num.positive?
      # prepend base62 charaters
      str = KEYS[num % BASE] + str
      num /= BASE
    end
    str
  end

  # Decodes base62 string to a base10 (decimal) number.
  def base62_decode(str)
    num = 0
    i = 0
    len = str.length - 1
    # while loop is faster than each_char or other 'idiomatic' way
    while i < str.length
      pow = BASE**(len - i)
      num += KEYS_HASH[str[i]] * pow
      i += 1
    end
    num
  end
end

# Simple Structured Secrets aims to implement GitHub's authentication
# token format as faithfully as possible. You can learn more about the
# design and properties of these tokens at the following link:
# https://github.blog/2021-04-05-behind-githubs-new-authentication-token-formats/
class SimpleStructuredSecrets
  class Error < StandardError; end

  require "zlib"
  require "securerandom"
  include Base62

  attr_accessor :org, :type

  def initialize(org, type)
    raise "Prefix is too long." if org.length + type.length > 10

    @org = org
    @type = type
  end

  # Generate a Simple Structured Secret token.
  #
  # Example:
  #   >> SimpleStructuredSecret.generate
  #   => "tk_GUkLdIZV8xnQQZobkuynSyyPkcweVm14nosQ"
  def generate
    random = base62_encode(SecureRandom.rand(10**60)).to_s[0...30]
    "#{@org}#{@type}_#{random}#{calc_checksum(random)}"
  end

  # Calculate the base62-encoded CRC32 checksum for a given input string.
  # When necessary, this value will be left-padded with 0 to ensure it's
  # always 6 characters long.
  #
  # Example:
  #   >> SimpleStructuredSecrets.calc_checksum("GUkLdIZV8xnQQZobkuynSyyPkcweVm")
  #   => "14nosQ"
  #
  # Arguments:
  #   secret: (String)
  def calc_checksum(secret)
    base62_encode(Zlib.crc32(secret)).ljust(6, "0")
  end

  # Validate a given Simple Structured Secret token.
  # Note that this only indicates whether a given token is in the correct
  # form and has a valid checksum. You will still need to implement your
  # own logic for checking the validity of tokens you've issued.
  #
  # Example:
  #   >> SimpleStructuredSecrets.validate("tk_GUkLdIZV8xnQQZobkuynSyyPkcweVm14nosQ")
  #   => true
  #
  # Arguments:
  #   secret: (String)
  def validate(secret)
    random = /(?<=_)[A-Za-z0-9]{30}/.match(secret).to_s
    calc_checksum(random) == secret.chars.last(6).join
  end

  # Append a Simple Structured Secret header to a provided string.
  # This is useful in cases where you'd like to realize the secret
  # scanning benefits of SSS with other token formats.
  #
  # Example:
  #   >> SimpleStructuredSecrets.generate_header("5be426ee126b88f9587bbbe767a7592c")
  #   => "tk_1e6YXE_5be426ee126b88f9587bbbe767a7592c"
  #
  # Arguments:
  #   str: (String)
  def generate_header(str)
    "#{@org}#{@type}_#{calc_checksum(str)}_#{str}"
  end

  # Validate a Simple Structured Secret header for a given string.
  #
  # Example:
  #   >> SimpleStructuredSecrets.validate_header("tk_1e6YXE_5be426ee126b88f9587bbbe767a7592c")
  #   => true
  #
  # Arguments:
  #   str: (String)
  def validate_header(str)
    matches = /(?<prefix>.*)_(?<checksum>[A-Za-z0-9]{6})_(?<string>.*)/.match(str)
    calc_checksum(matches["string"]) == matches["checksum"]
  end
end
