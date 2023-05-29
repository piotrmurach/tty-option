# frozen_string_literal: true

require_relative "lib/tty/option/version"

Gem::Specification.new do |spec|
  spec.name          = "tty-option"
  spec.version       = TTY::Option::VERSION
  spec.authors       = ["Piotr Murach"]
  spec.email         = ["piotr@piotrmurach.com"]
  spec.summary       = "An intuitive and flexible command line parser."
  spec.description   = "Parser for command line arguments, keywords, flags, options and environment variables."
  spec.homepage      = "https://ttytoolkit.org"
  spec.license       = "MIT"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["bug_tracker_uri"] = "https://github.com/piotrmurach/tty-option/issues"
  spec.metadata["changelog_uri"] = "https://github.com/piotrmurach/tty-option/blob/master/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://www.rubydoc.info/gems/tty-option"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["source_code_uri"] = "https://github.com/piotrmurach/tty-option"

  spec.files = Dir["lib/**/*"]
  spec.extra_rdoc_files = ["README.md", "CHANGELOG.md", "LICENSE.txt"]
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.0.0"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", ">= 3.0"
end
