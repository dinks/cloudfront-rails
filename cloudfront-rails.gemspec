# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cloudfront/rails/version'

Gem::Specification.new do |spec|
  spec.name          = "cloudfront-rails"
  spec.version       = Cloudfront::Rails::VERSION
  spec.authors       = ["Dinesh V"]
  spec.email         = ["dinesh@blinkist.com"]

  spec.summary       = %q{ Whitelist Cloudfront Proxies }
  spec.description   = %q{ Whitelist Cloudfront Proxies for Rails so that request.ip and request.remote_ip work properly }
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-rails"

  spec.add_development_dependency "webmock"

  spec.add_dependency "rails", "~> 4.0"
  spec.add_dependency "httparty", ">= 0.13.7"

  spec.required_ruby_version = ">= 2.0"
end
