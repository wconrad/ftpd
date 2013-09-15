unless $:.include?(File.dirname(__FILE__) + '/../lib')
  $:.unshift(File.dirname(__FILE__) + '/../lib')
end

require 'ftpd'
require 'stringio'
require 'thread'
require 'timecop'
require 'tmpdir'

