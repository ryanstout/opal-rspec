# -*- encoding: utf-8 -*-
require 'rake'
require File.expand_path('../lib/opal/rspec/version', __FILE__)

Gem::Specification.new do |s|
  s.name         = 'opal-rspec'
  s.version      = Opal::RSpec::VERSION
  s.author       = 'Adam Beynon'
  s.email        = 'adam.beynon@gmail.com'
  s.homepage     = 'http://opalrb.org'
  s.summary      = 'RSpec for Opal'
  s.description  = 'Opal compatible rspec library'

  s.files = `git ls-files`.split("\n") + FileList['rspec*/**/*.rb']

  s.require_paths  = ['lib']

  s.add_dependency 'opal', ['>= 0.8.0.rc1', '< 1.0']
  # Opal now does not include minitest but we need it for Sprockets/test execution
  s.add_dependency 'opal-minitest', '<= 0.4'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'yard'
end

