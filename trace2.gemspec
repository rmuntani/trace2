# frozen_string_literal: true

TRACE2_GEMSPEC = Gem::Specification.new do |s|
  s.name        = 'trace2'
  s.version     = '1.0.1'
  s.date        = '2020-08-27'
  s.summary     = 'Check the runtime dependencies of your classes'
  s.description = 'Check the runtime dependencies of your classes'
  s.authors     = ['Raphael Montani']
  s.email       = 'raphael.muntani@gmail.com'
  s.files       = Dir['lib/**/*']
  s.extensions  = ['ext/trace2/extconf.rb']
  s.executables << 'trace2'
  s.license = 'MIT'
end
