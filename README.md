# Sssecrets

[![Gem Version](https://badge.fury.io/rb/sssecrets.svg)](https://badge.fury.io/rb/sssecrets) [![RubyDoc](https://img.shields.io/static/v1?url=https%3A%2F%2Frubydoc.info%2Fgems%2Fsssecrets&label=RubyDoc&message=sssecrets&color=informational)](https://rubydoc.info/gems/sssecrets) [![Build](https://github.com/chtzvt/sssecrets/actions/workflows/main.yml/badge.svg)](https://github.com/chtzvt/sssecrets/actions/workflows/main.yml) [![Publish](https://github.com/chtzvt/sssecrets/actions/workflows/release.yml/badge.svg)](https://github.com/chtzvt/sssecrets/actions/workflows/release.yml) 


Welcome to sssecrets: **S**imple **S**tructured **Secrets**. Sssecrets is a library for generating secrets (like API tokens, etc) in line with best practices.

Sssecrets is a reusable implementation of GitHub's [API token format](https://github.blog/2021-04-05-behind-githubs-new-authentication-token-formats/) (which is also used by [NPM](https://github.blog/2021-09-23-announcing-npms-new-access-token-format/)), and it's designed to make it simple for developers to issue secure secret tokens that are easy to detect when leaked. 

You can learn more about GitHub's design process and the properties of this API token format on the [GitHub blog](https://github.blog/2021-04-05-behind-githubs-new-authentication-token-formats/).

### Want to use Sssecrets with Devise?

Check out [this demo](https://github.com/chtzvt/sssecrets-devise) to learn how you can use sssecrets as a drop-in replacement for the framework's [built-in friendly token generator](https://github.com/heartcombo/devise/blob/main/lib/devise.rb#L507).

## Why Structured Secrets?

If you're a developer and your application issues some kind of access tokens (API keys, PATs, etc), it's important to format these in a way that both identifies the string as a secret token and provides insight into its permissions. For bonus points, you should also provide example (dummy) tokens and regexes for them in your documentation.

Simple Structured Secrets help solve this problem: They're a compact format with properties that are optimized for detection with static analysis tools. That makes it possible to automatically detect when secrets are leaked in a codebase using features like [GitHub Secret Scanning](https://docs.github.com/en/code-security/secret-scanning/about-secret-scanning) or GitLab Secret Detection.

Here's an example. HashiCorp Vault's API access tokens look like this ([ref](https://developer.hashicorp.com/vault/api-docs#authentication)):

`f3b09679-3001-009d-2b80-9c306ab81aa6`

You might think that this is pretty is a pretty easy pattern to search for, but here's the issue: It's just a [UUID string](https://en.wikipedia.org/wiki/Universally_unique_identifier).

While random, strings in this format are used in many places for non-sensitive purposes. Meaning that, given a random UUID formatted string, it's impossible to know whether it's a sensitive API credential or a garden-variety identifier for something mundane. In cases like these, secret scanning can't help much.

## What's in a Structured Secret? 

Structured secrets have three parts:

- A prefix (2-10 characters, defined by you)
- 30 characters of randomness
- A 6 character checksum

That's it! 

Here's the format:

`[prefix]_[randomness][checksum]`

An example Sssecret, with an `org` of `t` and a `type` of `k`, looks like this:

`tk_GNrRoBa1p9nuwm7XrWkrhYUNQ7edOw4GUp8I`

### Prefix

Token prefixes are a simple and effective method to make tokens identifiable. [Slack](https://api.slack.com/authentication/token-types), [Stripe](https://stripe.com/docs/api/authentication), [GitHub](https://github.blog/2021-04-05-behind-githubs-new-authentication-token-formats/#identifiable-prefixes), and others have adopted this approach to great effect. 

Sssecrets allows you to provide two abbreviated strings, `org` and `type`, which together make up the token prefix. Generally, `org` would be used to specify an overarching identifier (like your company or app), while `type` is intended to identify the token type (i.e., OAuth tokens, refresh tokens, etc) in some way. To maintain a compact and consistent format for Sssecret tokens, `org` and `type` together should not exceed 10 characters in length.

### Entropy 

Simple Structured Secret tokens have an entropy of 178:

`Math.log(((“a”..“z”).to_a + (“A”..“Z”).to_a + (0..9).to_a).length)/Math.log(2) * 30 = 178`

*See the [GitHub blog](https://github.blog/2021-04-05-behind-githubs-new-authentication-token-formats/#token-entropy).*

### Checksum

The random component of the token is used to calculate a CRC32 checksum. This checksum is encoded in Base62 and padded with leading zeroes to ensure it's always 6 characters in length.

The token checksum can be used as a first-pass validity check. Using these checksums, false positives can be more or less eliminated when a codebase is being scanned for secrets, as fake tokens can be ignored without the need to query a backend or database.

_Note that this library can only check whether a given token is in the correct form and has a valid checksum. To fully determine whether a given token is active, you'll still need to implement your own logic for checking the validity of tokens you've issued._

_Another note: Because Sssecrets uses the same format as GitHub tokens, you can also perform offline validation of GitHub-issued secrets with `SimpleStructuredSecrets#validate`._

## Installation

Add this gem to your application's Gemfile:

```ruby
gem 'sssecrets'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install sssecrets

## Usage

Sssecrets is designed to be simple and straightforward to use. Here's an example:

```ruby
require 'sssecrets'

test = SimpleStructuredSecrets.new("t", "k")
tok = test.generate

puts "#{tok} is valid!" if test.validate(tok)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/chtzvt/sssecrets.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
