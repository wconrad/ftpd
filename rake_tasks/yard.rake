require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.options += ['-o', 'doc-api']
end
