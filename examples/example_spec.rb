# encoding: utf-8

# Authour: Michael de Silva <michael@mwdesilva.com>
# CEO @ http://omakaselabs.com / Mentor @ http://railsphd.com
# https://twitter.com/bsodmike / https://github.com/bsodmike

# This is an example for using Ftpd as a means for spec driving
# interaction with a 'dummy' ftp server via RSpec.  In this example we
# assume the client is implemented via `Fetcher::FTPFetcher`.

unless $:.include?(File.dirname(__FILE__) + '/../lib')
  $:.unshift(File.dirname(__FILE__) + '/../lib')
end

require 'net/ftp'
require 'ftpd'
require 'tmpdir'

# This is an example client spec driven via the use of Ftpd within the
# specs.  The specs spawn a 'dummy' Ftpd server and ensure this client
# operates as expected.

module Fetcher

  # This is the code under test, a simple fetcher that logs into an
  # FTP site, changes to a directlry, and gets a list of files.

  class FTPFetcher

    # @param host [String] ftp host to connect to.
    # @param user [String] username.
    # @param pwd [String] password.
    # @param dir [String] remote directory to change to.

    def initialize(host, user, pwd, dir)
      @host = host
      @user = user
      @pwd = pwd
      @dir = dir
      @ftp = Net::FTP.new
    end

    # @param port [Fixnum] port to connect to, 21 by default.
    # @return [Array] list of files in the current directory.

    def connect_and_list(port = 21)
      @ftp.debug_mode = true if ENV['DEBUG'] == "true"
      @ftp.passive = true
      @ftp.connect @host, port
      @ftp.login @user, @pwd
      @ftp.chdir @dir
      @ftp.nlst
    end

  end
end

describe Fetcher::FTPFetcher do

  # This `Driver` tells Ftpd how to authenticate and how to interact
  # with the file systme.  In this example, the file system is
  # read-only and contains a single file.

  class Driver
    def initialize
      @data_dir = Dir.mktmpdir
      at_exit {FileUtils.rm_rf(@data_dir)}
      FileUtils.touch File.expand_path('report.txt', @data_dir)
    end
    def authenticate(user, pwd); true; end
    def file_system(user); Ftpd::ReadOnlyDiskFileSystem.new(@data_dir); end
  end

  let(:server) do
    server = Ftpd::FtpServer.new(Driver.new)
    server.interface = "127.0.0.1"
    server.start
    server
  end

  let(:subject) do
    Fetcher::FTPFetcher.new('127.0.0.1', 'user', 'password', '/')
  end

  describe "#connect_and_list" do

    it "should connect to the FTP server and find 'report.txt' in the Array returned" do
      result = subject.connect_and_list(server.bound_port)
      expect(result).to include('report.txt')
    end

  end
end
