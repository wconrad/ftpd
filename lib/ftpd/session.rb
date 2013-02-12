#!/usr/bin/env ruby

require 'ftpd/error'

module Ftpd
  class Session

    include Error

    def initialize(args)
      @driver = args[:driver]
      @socket = args[:socket]
      @socket.encrypt if args[:implicit_tls]
      @data_path = @cwd = args[:data_path].realpath
      @name_prefix = '/'
      @debug_path = args[:debug_path]
      @data_type = 'A'
      @mode = 'S'
      @format = 'N'
      @structure = 'F'
      @response_delay = args[:response_delay]
      @data_channel_protection_level = :clear
    end

    def run
      reply "220 FakeFtpServer"
      @state = :user
      catch :done do
        loop do
          begin
            s = get_command
            syntax_error unless s =~ /^(\w+)(?: (.*))?$/
            command, argument = $1.downcase, $2
            unless VALID_COMMANDS.include?(command)
              error "500 Syntax error, command unrecognized: #{s}"
            end
            method = 'cmd_' + command
            unless self.class.private_method_defined?(method)
              error "502 Command not implemented: #{command}"
            end
            send(method, argument)
          rescue CommandError => e
            reply e.message
          rescue Errno::ECONNRESET, Errno::EPIPE
          end
        end
      end
    end

    private

    VALID_COMMANDS = [
      "abor",
      "acct",
      "allo",
      "appe",
      "auth",
      "pbsz",
      "cdup",
      "cwd",
      "dele",
      "help",
      "list",
      "mkd",
      "mode",
      "nlst",
      "noop",
      "pass",
      "pasv",
      "port",
      "prot",
      "pwd",
      "quit",
      "rein",
      "rest",
      "retr",
      "rmd",
      "rnfr",
      "rnto",
      "site",
      "smnt",
      "stat",
      "stor",
      "stou",
      "stru",
      "syst",
      "type",
      "user",
    ]

    def cmd_user(argument)
      syntax_error unless argument
      bad_sequence unless @state == :user
      @user = argument
      @state = :password
      reply "331 Password required"
    end

    def bad_sequence
      error "503 Bad sequence of commands"
    end

    def cmd_pass(argument)
      syntax_error unless argument
      bad_sequence unless @state == :password
      password = argument
      unless @driver.authenticate(@user, password)
        @state = :user
        error "530 Login incorrect"
      end
      reply "230 Logged in"
      @file_system = @driver.file_system(@user)
      @state = :logged_in
    end

    def cmd_quit(argument)
      syntax_error if argument
      check_logged_in
      reply "221 Byebye"
      @state = :user
    end

    def syntax_error
      error "501 Syntax error"
    end

    def cmd_port(argument)
      check_logged_in
      pieces = argument.split(/,/)
      syntax_error unless pieces.size == 6
      pieces.collect! do |s|
        syntax_error unless s =~ /^\d{1,3}$/
        i = s.to_i
        syntax_error unless (0..255) === i
        i
      end
      @data_hostname = pieces[0..3].join('.')
      @data_port = pieces[4] << 8 | pieces[5]
      reply "200 PORT command successful"
    end

    def cmd_stor(argument)
      close_data_server_socket_when_done do
        check_logged_in
        path = argument
        syntax_error unless path
        target = target_path(path)
        ensure_path_is_in_data_dir(target)
        contents = receive_file(path)
        write_file(target, contents)
        reply "226 Transfer complete"
      end
    end

    def cmd_retr(argument)
      close_data_server_socket_when_done do
        check_logged_in
        path = argument
        syntax_error unless path
        target = target_path(path)
        ensure_path_is_in_data_dir(target)
        contents = read_file(target)
        transmit_file(contents)
      end
    end

    def cmd_dele(argument)
      check_logged_in
      path = argument
      error "501 Path required" unless path
      target = target_path(path)
      ensure_path_is_in_data_dir(target)
      ensure_path_exists target
      File.unlink(target)
      reply "250 DELE command successful"
    end

    def cmd_list(argument)
      ls(argument, '-l')
    end

    def cmd_nlst(argument)
      ls(argument, '-1')
    end

    def ls(path, option)
      close_data_server_socket_when_done do
        check_logged_in
        ls_dir, ls_path = get_ls_dir_and_path(path)
        list = get_file_list(ls_dir, ls_path, option)
        transmit_file(list, 'A')
      end
    end

    def get_ls_dir_and_path(path)
      path = path || '.'
      target = target_path(path)
      target = realpath(target)
      ensure_path_is_in_data_dir(target)
      if target.to_s.index(@cwd.to_s) == 0
        ls_dir = @cwd
        ls_path = target.to_s[@cwd.to_s.length..-1]
      else
        raise
      end
      if ls_path =~ /^\//
        ls_path = $'
      end
      [ls_dir, ls_path]
    end

    def get_file_list(ls_dir, ls_path, option)
      command = [
        'ls',
        option,
        ls_path,
        '2>&1',
      ].compact.join(' ')
      list = Dir.chdir(ls_dir) do
        `#{command}`
      end
      list = "" if $? != 0
      list = list.gsub(/^total \d+\n/, '')
      list
    end

    def realpath(pathname)
      handle_system_error do
        basename = File.basename(pathname.to_s)
        if is_glob?(basename)
          pathname.dirname.realpath + basename
        else
          pathname.realpath
        end
      end
    end

    def is_glob?(filename)
      filename =~ /[.*]/
    end

    def cmd_type(argument)
      check_logged_in
      syntax_error unless argument =~ /^(\S)(?: (\S+))?$/
      type_code = $1
      format_code = $2
      set_type(type_code)
      set_format(format_code)
      reply "200 Type set to #{@data_type}"
    end

    def set_type(type_code)
      name, implemented = DATA_TYPES[type_code]
      error "504 Invalid type code" unless name
      error "504 Type not implemented" unless implemented
      @data_type = type_code
    end

    def set_format(format_code)
      format_code ||= 'N'
      name, implemented = FORMAT_TYPES[format_code]
      error "504 Invalid format code" unless name
      error "504 Format not implemented" unless implemented
      @data_format = format_code
    end

    def cmd_mode(argument)
      syntax_error unless argument
      check_logged_in
      name, implemented = TRANSMISSION_MODES[argument]
      error "504 Invalid mode code" unless name
      error "504 Mode not implemented" unless implemented
      @mode = argument
      reply "200 Mode set to #{name}"
    end

    def cmd_stru(argument)
      syntax_error unless argument
      check_logged_in
      name, implemented = FILE_STRUCTURES[argument]
      error "504 Invalid structure code" unless name
      error "504 Structure not implemented" unless implemented
      @structure = argument
      reply "200 File structure set to #{name}"
    end

    def cmd_noop(argument)
      syntax_error if argument
      reply "200 Nothing done"
    end

    def cmd_pasv(argument)
      check_logged_in
      if @data_server
        reply "200 Already in passive mode"
      else
        @data_server = TCPServer.new('localhost', 0)
        ip = @data_server.addr[3]
        port = @data_server.addr[1]
        quads = [
          ip.scan(/\d+/),
          port >> 8,
          port & 0xff,
        ].flatten.join(',')
        reply "227 Entering passive mode (#{quads})"
      end
    end

    def cmd_cwd(argument)
      check_logged_in
      target = if argument =~ %r"^/(.*)$"
                 @data_path + $1
               else
                 @cwd + argument
               end
      ensure_path_is_in_data_dir(target)
      restore_cwd_on_error do
        @cwd = target
        @name_prefix = 
          if argument =~ %r"^/"
            argument
          else
            File.expand_path(argument, @name_prefix)
          end
        unless @file_system.exists?(@name_prefix)
          error '550 No such file or directory'
        end
        pwd
      end
    end

    def cmd_cdup(argument)
      check_logged_in
      cmd_cwd('..')
    end

    def cmd_pwd(argument)
      check_logged_in
      pwd
    end

    def cmd_auth(security_scheme)
      if @socket.encrypted?
        error "503 AUTH already done"
      end
      unless security_scheme =~ /^TLS(-C)?$/i
        error "500 Security scheme not implemented: #{security_scheme}"
      end
      reply "234 AUTH #{security_scheme} OK."
      @socket.encrypt
    end

    def cmd_pbsz(buffer_size)
      syntax_error unless buffer_size =~ /^\d+$/
      buffer_size = buffer_size.to_i
      unless @socket.encrypted?
        error "503 PBSZ must be preceded by AUTH"
      end
      unless buffer_size == 0
        error "501 PBSZ=0"
      end
      reply "200 PBSZ=0"
      @protection_buffer_size_set = true
    end

    def cmd_prot(level_arg)
      level_code = level_arg.upcase
      unless @protection_buffer_size_set
        error "503 PROT must be preceded by PBSZ"
      end
      level = DATA_CHANNEL_PROTECTION_LEVELS[level_code]
      unless level
        error "504 Unknown protection level"
      end
      unless level == :private
        error "536 Unsupported protection level #{level}"
      end
      @data_channel_protection_level = level
      reply "200 Data protection level #{level_code}"
    end

    def pwd
      reply %Q(257 "#{sanitized_cwd}" is current directory)
    end

    def relative_to_data_path(path)
      data_path = realpath(@data_path).to_s
      path = realpath(path).to_s
      path = path.gsub(data_path, '')
      path = '/' if path.empty?
      path
    end

    def sanitized_cwd
      relative_to_data_path(@cwd)
    end

    TRANSMISSION_MODES = {
      'B'=>['Block', false],
      'C'=>['Compressed', false],
      'S'=>['Stream', true],
    }

    FORMAT_TYPES = {
      'N'=>['Non-print', true],
      'T'=>['Telnet format effectors', false],
      'C'=>['Carriage Control (ASA)', false],
    }

    DATA_TYPES = {
      'A'=>['ASCII', true],
      'E'=>['EBCDIC', false],
      'I'=>['BINARY', true],
      'L'=>['LOCAL', false],
    }

    FILE_STRUCTURES = {
      'R'=>['Record', false],
      'F'=>['File', true],
      'P'=>['Page', false],
    }

    DATA_CHANNEL_PROTECTION_LEVELS = {
      'C'=>:clear,
      'S'=>:safe,
      'E'=>:confidential,
      'P'=>:private
    }

    def check_logged_in
      return if @state == :logged_in
      error "530 Not logged in"
    end

    def ensure_path_is_in_data_dir(path)
      unless child_path_of?(@data_path, path)
        error "550 Access denied"
      end
    end

    def ensure_path_exists(path)
      unless File.exists?(path)
        error '450 No such file or directory'
      end
    end

    def child_path_of?(parent, child)
      child.cleanpath.to_s.index(parent.cleanpath.to_s) == 0
    end

    def target_path(path)
      path = Pathname.new(path)
      base, path = if path.to_s =~ /^\/(.*)/
                     [@data_path, $1]
                   else
                     [@cwd, path]
                   end
      base + path
    end

    def read_file(path)
      handle_system_error do
        File.open(path, 'rb') do |file|
          file.read
        end
      end
    end

    def write_file(dest, contents)
      handle_system_error do
        File.open(dest, 'w') do |file|
          file.write(contents)
        end
      end
    end

    def handle_system_error
      begin
        yield
      rescue SystemCallError => e
        error "550 #{e}"
      end
    end

    def transmit_file(contents, data_type = @data_type)
      open_data_connection do |data_socket|
        contents = unix_to_nvt_ascii(contents) if data_type == 'A'
        data_socket.write(contents)
        debug("Sent #{contents.size} bytes")
        reply "226 Transfer complete"
      end
    end

    def receive_file(path)
      open_data_connection do |data_socket|
        contents = data_socket.read
        contents = nvt_ascii_to_unix(contents) if @data_type == 'A'
        debug("Received #{contents.size} bytes")
        contents
      end
    end

    def unix_to_nvt_ascii(s)
      return s if s =~ /\r\n/
      s.gsub(/\n/, "\r\n")
    end

    def nvt_ascii_to_unix(s)
      s.gsub(/\r\n/, "\n")
    end

    def open_data_connection(&block)
      reply "150 Opening #{data_connection_description}"
      if @data_server
        if encrypt_data?
          open_passive_tls_data_connection(&block)
        else
          open_passive_data_connection(&block)
        end
      else
        if encrypt_data?
          open_active_tls_data_connection(&block)
        else
          open_active_data_connection(&block)
        end
      end
    end

    def data_connection_description
      [
        DATA_TYPES[@data_type][0],
        "mode data connection",
        ("(TLS)" if encrypt_data?)
      ].compact.join(' ')
    end

    def encrypt_data?
      @data_channel_protection_level != :clear
    end

    def open_active_data_connection
      data_socket = TCPSocket.new(@data_hostname, @data_port)
      begin
        yield(data_socket)
      ensure
        data_socket.close
      end
    end

    def open_active_tls_data_connection
      open_active_data_connection do |socket|
        make_tls_connection(socket) do |ssl_socket|
          yield(ssl_socket)
        end
      end
    end

    def open_passive_data_connection
      data_socket = @data_server.accept
      begin
        yield(data_socket)
      ensure
        data_socket.close
      end
    end

    def close_data_server_socket_when_done
      yield
    ensure
      close_data_server_socket
    end

    def close_data_server_socket
      return unless @data_server
      @data_server.close
      @data_server = nil
    end

    def open_passive_tls_data_connection
      open_passive_data_connection do |socket|
        make_tls_connection(socket) do |ssl_socket|
          yield(ssl_socket)
        end
      end
    end

    def make_tls_connection(socket)
      ssl_socket = OpenSSL::SSL::SSLSocket.new(socket, @socket.ssl_context)
      ssl_socket.accept
      begin
        yield(ssl_socket)
      ensure
        ssl_socket.close
      end
    end

    def get_command
      s = @socket.gets
      throw :done if s.nil?
      s = s.chomp
      debug(s)
      s
    end

    def reply(s)
      if @response_delay.to_i != 0
        debug "#{@response_delay} second delay before replying"
        sleep @response_delay
      end
      debug(s)
      @socket.puts(s)
    end

    def debug(*s)
      return unless debug?
      File.open(@debug_path, 'a') do |file|
        file.puts(*s)
      end
    end

    def debug?
      ENV['DEBUG'].to_i != 0
    end

    def restore_cwd_on_error
      orig_cwd = @cwd
      yield
    rescue
      @cwd = orig_cwd
      raise
    end

  end
end
