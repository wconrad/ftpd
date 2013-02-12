require 'cucumber/rake/task'

Cucumber::Rake::Task.new(:features) do |t|
  t.fork = true
end

task :cucumber => [:features]
task :default => [:cucumber]
