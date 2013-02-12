
task :default => [:test]

desc 'Run all tests'
task :test => ['test:spec', 'test:cucumber']
task :default => [:test]
