# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require_relative 'emerald_odm/version'

Gem::Specification.new do |spec|
  spec.name          = 'emerald_odm'
  spec.version       = EmeraldODM::VERSION
  spec.authors       = ['mikael']
  spec.email         = ['mikael.santilio@gmail.com']

  spec.summary       = 'MongoDB ODM'
  spec.description   = 'Simple MongoDB ODM'
  spec.homepage      = 'https://github.com/SPD-DataOps/atlas-email-validation'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.metadata['allowed_push_host'] = 'https://github.com/SPD-DataOps/atlas-email-validation'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/SPD-DataOps/atlas-email-validation'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'dotenv'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'simplecov'

  spec.add_dependency 'mongo'

end
