# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mcblocky/version'

Gem::Specification.new do |spec|
  spec.name          = "mcblocky"
  spec.version       = McBlocky::VERSION
  spec.version       = "#{spec.version}-alpha-#{ENV['TRAVIS_BUILD_NUMBER']}" if ENV['TRAVIS']
  spec.authors       = ["Michael Limiero"]
  spec.email         = ["mike5713@gmail.com"]

  spec.summary       = %q{Minecraft command blocks as Ruby code}
  spec.description   = %q{McBlocky is a Ruby DSL for creating Minecraft command block contraptions and maps.}
  spec.homepage      = "https://github.com/DeltaWhy/mcblocky"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"

  spec.add_runtime_dependency "thor", "~> 0.19"
  spec.add_runtime_dependency "listen", "~> 3.0"
end
