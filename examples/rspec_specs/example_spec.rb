# encoding: utf-8

# Authour: Michael de Silva <michael@mwdesilva.com>
# CEO @ http://omakaselabs.com / Mentor @ http://railsphd.com
# https://twitter.com/bsodmike / https://github.com/bsodmike

# This is an example for using Ftpd as a means for spec driving
# interaction with a 'dummy' ftp server via RSpec.  In this example we
# assume the client is implemented via `Fetcher::FTPFetcher`.

unless $:.include?(File.dirname(__FILE__) + '/../../lib')
  $:.unshift(File.dirname(__FILE__) + '/../../lib')
end

require 'net/ftp'
require 'ftpd'
require 'tmpdir'

DATA_DIR = File.expand_path('../rspec_specs/ftp_documents', File.dirname(__FILE__))

# This is an example client spec driven via the use of Ftpd within the
# specs.  The specs spawn a 'dummy' Ftpd server and ensure this client
# operates as expected.

module Fetcher
  class FTPFetcher

    # @param host [String] ftp host to connect to.
    # @param user [String] username.
    # @param pwd [String] password.
    # @param dir [String] remote directory to change to.

    def initialize(host, user, pwd, dir)
      @file_path = File.expand_path('../rspec_specs/tmp', File.dirname(__FILE__))
      create_file_path
      @host = host
      @user = user
      @pwd = pwd
      @dir = dir
      @ftp = Net::FTP.new
    end

    attr_reader :file_path, :host, :user, :pwd, :dir
    attr_accessor :ftp

    # @param port [Fixnum] port to connect to, 21 by default.
    # @return [Array] list of files in the current directory.

    def connect_and_list(port = 21)
      ftp.debug_mode = true if ENV['DEBUG'] == "true"
      ftp.passive = true
      ftp.connect(host, port)
      ftp.login(user, pwd)
      ftp.chdir(dir)
      ftp.nlst
    end

    private
    def create_file_path
      Dir.mkdir(file_path, 0755) unless File.exists?(file_path)
    end
  end
end

# This is the `Driver` for Ftpd.  In this example, the file system is
# considered as read-only.
class Driver
  def initialize(user, pwd, data_dir)
    @user = user
    @pwd = pwd
    @data_dir = data_dir
  end
  def authenticate(user, pwd); true; end
  def file_system(user); Ftpd::ReadOnlyDiskFileSystem.new(@data_dir); end
end

describe Fetcher::FTPFetcher do
  let(:server) do
    server = Ftpd::FtpServer.new Driver.new("spec_user", "spec_pwd", DATA_DIR)
    server.interface = "127.0.0.1"
    server.start
    puts "Server listening on port #{server.bound_port}"
    server
  end

  let(:subject) do
    Fetcher::FTPFetcher.new('lvh.me', 'u', 'p', '/')
  end

  # NOTE In this example, the client implements `connect_and_list()`
  # where a connection is establishd and the files at the remote root
  # path are returned as an `Array`.
  #
  # In this example, a file named `report.txt` is located in
  # `examples/rspec_specs/ftp_documents` - in the second spec below, we
  # expect to find this file on our 'dummy' Ftpd server.

  describe "#connect_and_list" do

    it "should connect and not raise errors" do
      expect{subject.connect_and_list(server.bound_port)}.not_to raise_error
    end

    it "should connect to the FTP server and return an Array of files" do
      result = subject.connect_and_list(server.bound_port)
      expect(result).to be_a(Array)
      expect(result).not_to be_empty
    end

    it "should connect to the FTP server and find 'report.txt' in the Array returned" do
      result = subject.connect_and_list(server.bound_port)
      expect(result.pop).to eq("report.txt")
    end

  end
end
