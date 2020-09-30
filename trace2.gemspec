# frozen_string_literal: true

TRACE2_GEMSPEC = Gem::Specification.new do |s|
  s.authors     = ['Raphael Montani']
  s.date        = '2020-09-27'
  s.description = 'Check the runtime dependencies of your classes'
  s.email       = 'raphael.muntani@gmail.com'

  s.executables << 'trace2'
  s.extensions  = ['ext/trace2/extconf.rb']
  s.files       = Dir['lib/**/*']

  s.license = 'MIT'

  s.name        = 'trace2'
  s.summary     = 'Check the runtime dependencies of your classes'
  s.version     = '1.0.1'
  s.homepage    = 'https://github.com/rmuntani/trace2'
  s.metadata    = { 'source_code_uri' => 'https://github.com/rmuntani/trace2' }
end
