require 'fileutils'
require 'forwardable'

class TestServer

  extend Forwardable
  include FileUtils

  def initialize
    @temp_dir = Ftpd::TempDir.new
    @server = Ftpd::FtpServer.new(@temp_dir.path)
    @templates = TestFileTemplates.new
  end

  def close
    @server.close
    @temp_dir.rm
  end

  def host
    'localhost'
  end

  def add_file(path)
    full_path = temp_path(path)
    mkdir_p File.dirname(full_path)
    File.open(full_path, 'wb') do |file|
      file.puts @templates[File.basename(full_path)]
    end
  end

  def has_file?(path)
    full_path = temp_path(path)
    File.exists?(full_path)
  end

  def file_contents(path)
    full_path = temp_path(path)
    File.open(full_path, 'rb', &:read)
  end

  def_delegator :@server, :password
  def_delegator :@server, :port
  def_delegator :@server, :user

  private

  def temp_path(path)
    File.expand_path(path, @temp_dir.path)
  end

end
