require File.expand_path('../lib/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = 'pakyow-assets'
  spec.summary       = 'Pakyow Assets'
  spec.description   = 'Asset Handling for Pakyow'
  spec.author        = 'Bryan Powell'
  spec.email         = 'bryan@metabahn.com'
  spec.homepage      = 'http://pakyow.org'
  spec.version       = Pakyow::Assets::VERSION
  spec.require_path  = 'lib'
  spec.files         = `git ls-files`.split("\n")
  spec.license       = 'MIT'

  spec.add_dependency('pakyow-support', '>= 0.11')
  spec.add_dependency('pakyow-core', '>= 0.11')
  spec.add_dependency('pakyow-presenter', '>= 0.11')

  spec.add_dependency('sass', '~> 3.4')
  spec.add_dependency('yui-compressor', '~> 0.12')
end
