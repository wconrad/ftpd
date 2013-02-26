#!/usr/bin/env ruby

module Ftpd
  class Session

    include Error

    def initialize(opts)
      @driver = opts[:driver]
      @socket = opts[:socket]
      @interface = opts[:interface]
      @tls = opts[:tls]
      if @tls == :implicit
        @socket.encrypt
      end
      @name_prefix = '/'
      @debug_path = opts[:debug_path]
      @debug = opts[:debug]
      @data_type = 'A'
      @mode = 'S'
      @format = 'N'
      @structure = 'F'
      @response_delay = opts[:response_delay]
      @data_channel_protection_level = :clear
    end

    def run
      reply "220 ftpd"
      @state = :user
      catch :done do
        loop do
          begin
            s = get_command
            syntax_error unless s =~ /^(\w+)(?: (.*))?$/
            command, argument = $1.downcase, $2
            method = 'cmd_' + command
            unless respond_to?(method, true)
              unrecognized_error s
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

    def cmd_allo(argument)
      ensure_logged_in
      syntax_error unless argument =~ /^\d+( R \d+)?$/
      command_not_needed
    end

    def cmd_syst(argument)
      syntax_error if argument
      reply "215 UNIX Type: L8"
    end

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
      set_file_system @driver.file_system(@user)
      @state = :logged_in
    end

    def cmd_quit(argument)
      syntax_error if argument
      ensure_logged_in
      reply "221 Byebye"
      @state = :user
    end

    def syntax_error
      error "501 Syntax error"
    end

    def cmd_port(argument)
      ensure_logged_in
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
        ensure_logged_in
        ensure_file_system_supports :write
        path = argument
        syntax_error unless path
        path = File.expand_path(path, @name_prefix)
        ensure_accessible path
        ensure_exists File.dirname(path)
        contents = receive_file(path)
        @file_system.write path, contents
        reply "226 Transfer complete"
      end
    end

    def cmd_retr(argument)
      close_data_server_socket_when_done do
        ensure_logged_in
        ensure_file_system_supports :read
        path = argument
        syntax_error unless path
        path = File.expand_path(path, @name_prefix)
        ensure_accessible path
        ensure_exists path
        contents = @file_system.read(path)
        transmit_file contents
      end
    end

    def cmd_dele(argument)
      ensure_logged_in
      ensure_file_system_supports :delete
      path = argument
      error "501 Path required" unless path
      path = File.expand_path(path, @name_prefix)
      ensure_accessible path
      ensure_exists path
      @file_system.delete path
      reply "250 DELE command successful"
    end

    def cmd_list(argument)
      close_data_server_socket_when_done do
        ensure_logged_in
        ensure_file_system_supports :list
        path = argument
        path ||= '.'
        path = File.expand_path(path, @name_prefix)
        list = @file_system.list(path)
        transmit_file(list, 'A')
      end
    end

    def cmd_nlst(argument)
      close_data_server_socket_when_done do
        ensure_logged_in
        ensure_file_system_supports :name_list
        path = argument
        path ||= '.'
        path = File.expand_path(path, @name_prefix)
        list = @file_system.name_list(path)
        transmit_file(list, 'A')
      end
    end

    def cmd_type(argument)
      ensure_logged_in
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
      ensure_logged_in
      name, implemented = TRANSMISSION_MODES[argument]
      error "504 Invalid mode code" unless name
      error "504 Mode not implemented" unless implemented
      @mode = argument
      reply "200 Mode set to #{name}"
    end

    def cmd_stru(argument)
      syntax_error unless argument
      ensure_logged_in
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
      ensure_logged_in
      if @data_server
        reply "200 Already in passive mode"
      else
        @data_server = TCPServer.new(@interface, 0)
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
      ensure_logged_in
      path = File.expand_path(argument, @name_prefix)
      ensure_accessible path
      ensure_exists path
      ensure_directory path
      @name_prefix = path
      pwd
    end

    def cmd_mkd(argument)
      syntax_error unless argument
      ensure_logged_in
      ensure_file_system_supports :mkdir
      path = File.expand_path(argument, @name_prefix)
      ensure_accessible path
      ensure_exists File.dirname(path)
      ensure_directory File.dirname(path)
      ensure_does_not_exist path
      @file_system.mkdir path
      reply %Q'257 "#{path}" created'
    end
    alias cmd_xmkd :cmd_mkd

    def cmd_rmd(argument)
      syntax_error unless argument
      ensure_logged_in
      ensure_file_system_supports :rmdir
      path = File.expand_path(argument, @name_prefix)
      ensure_accessible path
      ensure_exists path
      ensure_directory path
      @file_system.rmdir path
      reply '250 RMD command successful'
    end
    alias cmd_xrmd :cmd_rmd

    def ensure_file_system_supports(method)
      unless @file_system.respond_to?(method)
        unimplemented_error
      end
    end

    def ensure_logged_in
      return if @state == :logged_in
      error "530 Not logged in"
    end

    def ensure_accessible(path)
      unless @file_system.accessible?(path)
        error '550 Access denied'
      end
    end

    def ensure_exists(path)
      unless @file_system.exists?(path)
        error '550 No such file or directory'
      end
    end

    def ensure_does_not_exist(path)
      if @file_system.exists?(path)
        error '550 Already exists'
      end
    end

    def ensure_directory(path)
      unless @file_system.directory?(path)
        error '550 Not a directory'
      end
    end

    def ensure_tls_supported
      unless tls_enabled?
        error "534 TLS not enabled"
      end
    end

    def tls_enabled?
      @tls != :off
    end

    def cmd_cdup(argument)
      syntax_error if argument
      ensure_logged_in
      cmd_cwd('..')
    end
    alias cmd_xcup :cmd_cdup

    def cmd_pwd(argument)
      ensure_logged_in
      pwd
    end

    def cmd_auth(security_scheme)
      ensure_tls_supported
      if @socket.encrypted?
        error "503 AUTH already done"
      end
      unless security_scheme =~ /^TLS(-C)?$/i
        error "504 Security scheme not implemented: #{security_scheme}"
      end
      reply "234 AUTH #{security_scheme} OK."
      @socket.encrypt
    end

    def cmd_pbsz(buffer_size)
      ensure_tls_supported
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

    def cmd_rnfr(argument)
      ensure_logged_in
      ensure_file_system_supports :rename
      syntax_error unless argument
      from_path = File.expand_path(argument, @name_prefix)
      ensure_accessible from_path
      ensure_exists from_path
      @rename_from_path = from_path
      reply '350 RNFR accepted; ready for destination'
    end

    def cmd_rnto(argument)
      ensure_logged_in
      ensure_file_system_supports :rename
      syntax_error unless argument
      to_path = File.expand_path(argument, @name_prefix)
      ensure_accessible to_path
      ensure_does_not_exist to_path
      @file_system.rename(@rename_from_path, to_path)
      reply '250 Rename successful'
    end

    def self.unimplemented(command)
      method_name = "cmd_#{command}"
      define_method method_name do |arguments|
        unimplemented_error
      end
      private method_name
    end

    unimplemented :abor
    unimplemented :acct
    unimplemented :appe
    unimplemented :help
    unimplemented :rein
    unimplemented :rest
    unimplemented :site
    unimplemented :smnt
    unimplemented :stat
    unimplemented :stou

    def pwd
      reply %Q(257 "#{@name_prefix}" is current directory)
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

    def set_file_system(file_system)
      @file_system = FileSystemErrorTranslator.new(file_system)
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

    def command_not_needed
      reply '202 Command not needed at this site'
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
      @debug || ENV['FTPD_DEBUG'].to_i != 0
    end

  end
end
