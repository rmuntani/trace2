# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'trace2'
  s.version     = '0.6.5'
  s.date        = '2020-08-16'
  s.summary     = 'Check the runtime dependencies of your classes'
  s.description = 'Check the runtime dependencies of your classes'
  s.authors     = ['Raphael Montani']
  s.email       = 'raphael.muntani@gmail.com'
  s.files       = Dir['lib/**/*']
  s.extensions  = ['ext/trace2/extconf.rb']
  s.executables << 'trace2'
  s.license = 'MIT'
end
