require 'rake'
require 'rake/extensiontask'

spec = Gem::Specification.load('./trace2.gemspec')

Gem::PackageTask.new(spec) do |pkg|
end

Rake::ExtensionTask.new('trace2', spec) do |ext|
  ext.ext_dir = 'ext/trace2'
  ext.lib_dir = 'lib/trace2'
  ext.tmp_dir = 'tmp'
  ext.cross_compile = true
  ext.cross_platform = %w[x86-mingw32 x64-mingw32 x86-linux x86_64-linux]
end
