# -*- mode: ruby -*-
Gem::Specification.new do |s|
  s.name = 'ixtlan-audit'
  s.version = '0.3.2'

  s.summary = 'audit the controller actions for the current user'
  s.description = 'audit the controller actions for the current user. log that data into the database and allow to expire this log files (privacy protection) and be able to browse it from the UI'
  s.homepage = 'http://github.com/mkristian/ixtlan-audit'

  s.authors = ['Christian Meier']
  s.email = ['m.kristian@web.de']

  s.files = Dir['MIT-LICENSE']
  s.license = 'MIT'
#  s.files += Dir['History.txt']
  s.files += Dir['README.textile']
#  s.extra_rdoc_files = ['History.txt','README.textile']
  s.rdoc_options = ['--main','README.textile']
  s.files += Dir['lib/**/*']
  s.files += Dir['spec/**/*']
  s.files += Dir['features/**/*rb']
  s.files += Dir['features/**/*feature']
  s.test_files += Dir['spec/**/*_spec.rb']
  s.test_files += Dir['features/*.feature']
  s.test_files += Dir['features/step_definitions/*.rb']
  s.add_dependency 'slf4r', '~> 0.4.2'
  s.add_development_dependency 'rspec', '~> 2.6'
  s.add_development_dependency 'rake', '~> 10.0.3'
  s.add_development_dependency 'dm-core', '1.2.0'
  s.add_development_dependency 'dm-migrations', '1.2.0'
  s.add_development_dependency 'dm-sqlite-adapter', '1.2.0'
end

# vim: syntax=Ruby
