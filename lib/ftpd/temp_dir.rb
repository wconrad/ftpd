require 'fileutils'
require 'tmpdir'

module TempDir

  def make
    Dir.mktmpdir.tap do |path|
      at_exit do
        FileUtils.rm_rf path
        Dir.rmdir path if File.exists?(path)
      end
    end
  end
  module_function :make

end
