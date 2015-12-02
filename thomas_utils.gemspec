Gem::Specification.new do |s|
  s.name = 'thomas_utils'
  s.version = '0.1.13'
  s.license = 'Apache License 2.0'
  s.summary = 'Helper utilities gem used in a number of my projects'
  s.description = %q{Helper utilities gem used in a number of my projects.
  Includes future wrappers and provides some override methods for Ruby core classes
  that make defining behaviours easier to code.}
  s.authors = ['Thomas RM Rogers']
  s.email = 'thomasrogers03@gmail.com'
  s.files = Dir['{lib}/**/*.rb', 'bin/*', 'LICENSE.txt', '*.md']
  s.require_path = 'lib'
  s.homepage = 'https://www.github.com/thomasrogers03/thomas_utils'
  s.add_runtime_dependency 'concurrent-ruby', '~> 0.8'
  s.add_runtime_dependency 'workers', '~> 0.3'
end
