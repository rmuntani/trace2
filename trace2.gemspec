# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'trace2'
  s.version     = '0.1.0'
  s.date        = '2020-03-20'
  s.summary     = 'Check the runtime dependencies of your classes'
  s.description = 'Check the runtime dependencies of your classes'
  s.authors     = ['Raphael Montani']
  s.email       = 'raphael.muntani@gmail.com'
  s.files       = Dir['lib/**/*']
  s.executables << 'trace2'
  s.license = 'MIT'
end
