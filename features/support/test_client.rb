require 'double_bag_ftps'
require 'net/ftp'

class TestClient

  extend Forwardable
  include FileUtils

  def initialize(opts = {})
    @temp_dir = Ftpd::TempDir.new
    @ftp = make_ftp(opts)
    @templates = TestFileTemplates.new
  end

  def_delegators :@ftp,
  :chdir,
  :connect,
  :delete,
  :getbinaryfile,
  :gettextfile,
  :login,
  :ls,
  :nlst,
  :noop,
  :passive=,
  :pwd,
  :quit

  def raw(*command)
    @ftp.sendcmd *command.compact.join(' ')
  end

  def get(mode, remote_path)
    method = "get#{mode}file"
    @ftp.send method, remote_path, local_path(remote_path)
  end

  def put(mode, remote_path)
    method = "put#{mode}file"
    @ftp.send method, local_path(remote_path), remote_path
  end

  def add_file(path)
    full_path = temp_path(path)
    mkdir_p File.dirname(full_path)
    File.open(full_path, 'wb') do |file|
      file.puts @templates[File.basename(full_path)]
    end
  end

  def file_contents(path)
    File.open(temp_path(path), 'rb', &:read)
  end

  private

  RAW_METHOD_REGEX = /^send_(.*)$/

  def local_path(remote_path)
    temp_path(File.basename(remote_path))
  end

  def temp_path(path)
    File.expand_path(path, @temp_dir.path)
  end

  def make_ftp(opts)
    tls = opts[:tls]
    if tls
      make_tls_ftp
    else
      make_non_tls_ftp
    end
  end

  def make_tls_ftp
    ftp = DoubleBagFTPS.new
    context_opts = {
      :verify_mode => OpenSSL::SSL::VERIFY_NONE
    }
    ftp.ssl_context = DoubleBagFTPS.create_ssl_context(context_opts)
    ftp
  end

  def make_non_tls_ftp
    Net::FTP.new
  end

end
