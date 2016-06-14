# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bartleby/version'

Gem::Specification.new do |spec|
  spec.name          = "bartleby"
  spec.version       = Bartleby::VERSION
  spec.authors       = ["Sam Greenlee"]
  spec.email         = ["sam.a.greenlee@gmail.com"]

  spec.summary       = %q{A lightweight ORM.}
  spec.homepage      = "https://github.com/sgreenlee/bartleby"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = Dir.glob("lib/**/*") + %w{README.md LICENSE.txt}
  # spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'activesupport', '~> 4.0'
  spec.add_runtime_dependency 'sqlite3', '~> 1.3'

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", ["~> 3.1.0", '>= 3.1.0']
end
