lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "db_meta/version"

Gem::Specification.new do |spec|
  spec.name = "db_meta"
  spec.version = DbMeta::VERSION
  spec.license = "Apache-2.0"
  spec.authors = ["Thomi"]
  spec.email = ["thomas.steiner@ikey.ch"]

  spec.summary = "Database meta and core data extraction"
  spec.description = "Database meta and core data extraction."
  spec.homepage = "https://github.com/thomis/db_meta"

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.10"
  spec.add_development_dependency "standardrb", "~> 1.0"

  spec.add_dependency "ruby-oci8", "~> 2.2"
end
