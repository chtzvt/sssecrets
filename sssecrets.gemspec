# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "sssecrets"
  spec.version = "1.0.1"
  spec.authors = ["Charlton Trezevant"]

  spec.summary = "Simple Structured Secrets"
  spec.description = "Easily generate and validate structured secrets for your application"
  spec.homepage = "https://github.com/chtzvt/sssecrets"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/chtzvt/sssecrets"
  spec.metadata["github_repo"] = "ssh://github.com/chtzvt/sssecrets"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
