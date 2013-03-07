require 'cucumber/rake/task'

Cucumber::Rake::Task.new 'test:features' do |t|
  t.fork = true
end

task 'test:cucumber' => ['test:features']
task 'cucumber' => ['test:features']
