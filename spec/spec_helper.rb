unless $:.include?(File.dirname(__FILE__) + '/../lib')
  $:.unshift(File.dirname(__FILE__) + '/../lib')
end

require 'fileutils'
require 'ftpd'
require 'stringio'
require 'thread'
require 'timecop'
require 'tmpdir'

glob = File.expand_path('helpers/*.rb', File.dirname(__FILE__))
Dir[glob].sort.each do |helper_path|
  require helper_path
end
