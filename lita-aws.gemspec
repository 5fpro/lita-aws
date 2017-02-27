$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))
require 'lita-aws/version'

Gem::Specification.new do |spec|
  spec.name          = 'lita-aws'
  spec.version       = LitaAws::VERSION
  spec.authors       = ['marsz']
  spec.email         = ['marsz330@gmail.com']
  spec.description   = 'Lita plugin for managing AWS services on multple accounts'
  spec.summary       = 'Lita plugin for managing AWS services on multple accounts'
  spec.homepage      = 'https://github.com/5fpro/lita-aws'
  spec.license       = 'MIT'
  spec.metadata      = { 'lita_plugin_type' => 'handler' }

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(/^bin/) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|features)/)
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'lita', '>= 4.7'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'rspec', '>= 3.0.0'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'coveralls'
end
