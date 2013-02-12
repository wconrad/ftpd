require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new 'test:spec'
task :spec => ['test:spec']
