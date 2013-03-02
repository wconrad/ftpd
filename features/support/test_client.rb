require 'double_bag_ftps'
require 'net/ftp'

class TestClient

  extend Forwardable
  include FileUtils

  def initialize(opts = {})
    @temp_dir = Ftpd::TempDir.make
    @ftp = make_ftp(opts)
    @templates = TestFileTemplates.new
  end

  def close
    @ftp.close
  end

  def_delegators :@ftp,
  :chdir,
  :connect,
  :delete,
  :getbinaryfile,
  :gettextfile,
  :help,
  :login,
  :ls,
  :mkdir,
  :nlst,
  :noop,
  :passive=,
  :pwd,
  :rename,
  :rmdir,
  :quit,
  :system

  def raw(*command)
    @ftp.sendcmd command.compact.join(' ')
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
      file.write @templates[File.basename(full_path)]
    end
  end

  def file_contents(path)
    File.open(temp_path(path), 'rb', &:read)
  end

  def xpwd
    response = raw('XPWD')
    response[/"(.+)"/, 1]
  end

  def store_unique(local_path, remote_path)
    command = ['STOU', remote_path].compact.join(' ')
    File.open(temp_path(local_path), 'rb') do |file|
      @ftp.storbinary command, file, Net::FTP::DEFAULT_BLOCKSIZE
    end
  end

  private

  RAW_METHOD_REGEX = /^send_(.*)$/

  def local_path(remote_path)
    temp_path(File.basename(remote_path))
  end

  def temp_path(path)
    File.expand_path(path, @temp_dir)
  end

  def make_ftp(opts)
    tls_mode = opts[:tls] || :off
    case tls_mode
    when :off
      make_non_tls_ftp
    when :implicit
      make_tls_ftp(:implicit)
    when :explicit
      make_tls_ftp(:explicit)
    else
      raise "Unknown TLS mode: #{tls_mode}"
    end
  end

  def make_tls_ftp(ftps_mode)
    ftp = DoubleBagFTPS.new
    context_opts = {
      :verify_mode => OpenSSL::SSL::VERIFY_NONE
    }
    ftp.ssl_context = DoubleBagFTPS.create_ssl_context(context_opts)
    ftp.ftps_mode = ftps_mode
    ftp
  end

  def make_non_tls_ftp
    Net::FTP.new
  end

end
