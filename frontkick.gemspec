#! /usr/bin/env gem build
# encoding: utf-8

Gem::Specification.new do |gem|
  gem.name          = 'frontkick'
  gem.version       = File.read(File.expand_path('VERSION', File.dirname(__FILE__))).chomp
  gem.authors       = ["Naotoshi Seo"]
  gem.email         = ["sonots@gmail.com"]
  gem.homepage      = "https://github.com/sonots/frontkick"
  gem.summary       = "A wrapper of Open3#popen3 to execute a command easily"
  gem.description   = gem.summary

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  # for testing
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"

  # for debug
  gem.add_development_dependency "pry"
end
