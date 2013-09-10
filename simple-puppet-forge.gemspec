Gem::Specification.new do |s|
  s.name        = "simple-puppet-forge"
  s.version     = %x{git describe --tags}.split('-')[0..1].join('.')
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Erik Dalén"]
  s.email       = ["dalen@spotify.com"]
  s.summary     = %q{Simple Puppet Forge}
  s.description = %q{A simple implementation of the Puppet Forge.}
  s.license     = 'Apache v2'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features,examples}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency('json')
  s.add_dependency('sinatra')
end
