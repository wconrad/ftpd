#!/usr/bin/env ruby

module Ftpd
  class Session

    include Error
    include ListPath

    # @params session_config [SessionConfig] Session configuration
    # @param socket [TCPSocket, OpenSSL::SSL::SSLSocket] The socket

    def initialize(session_config, socket)
      @config = session_config
      @socket = socket
      if @config.tls == :implicit
        @socket.encrypt
      end
      @command_sequence_checker = init_command_sequence_checker
      set_socket_options
      @protocols = Protocols.new(@socket)
      initialize_session
    end

    def run
      catch :done do
        begin
          reply "220 #{server_name_and_version}"
          loop do
            begin
              s = get_command
              s = process_telnet_sequences(s)
              syntax_error unless s =~ /^(\w+)(?: (.*))?$/
              command, argument = $1.downcase, $2
              method = 'cmd_' + command
              unless respond_to?(method, true)
                unrecognized_error s
              end
              @command_sequence_checker.check command
              send(method, argument)
            rescue CommandError => e
              reply e.message
            end
          end
        rescue Errno::ECONNRESET, Errno::EPIPE
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
      sequence_error if @logged_in
      @user = argument
      if @config.auth_level > AUTH_USER
        reply "331 Password required"
        expect 'pass'
      else
        login(@user)
      end
    end

    def cmd_pass(argument)
      syntax_error unless argument
      @password = argument
      if @config.auth_level > AUTH_PASSWORD
        reply "332 Account required"
        expect 'acct'
      else
        login(@user, @password)
      end
    end

    def cmd_acct(argument)
      syntax_error unless argument
      account = argument
      login(@user, @password, account)
    end

    def cmd_quit(argument)
      syntax_error if argument
      ensure_logged_in
      reply "221 Byebye"
      @logged_in = false
    end

    def syntax_error
      error "501 Syntax error"
    end

    def cmd_port(argument)
      ensure_logged_in
      ensure_not_epsv_all
      pieces = argument.split(/,/)
      syntax_error unless pieces.size == 6
      pieces.collect! do |s|
        syntax_error unless s =~ /^\d{1,3}$/
        i = s.to_i
        syntax_error unless (0..255) === i
        i
      end
      hostname = pieces[0..3].join('.')
      port = pieces[4] << 8 | pieces[5]
      set_active_mode_address hostname, port
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
        contents = receive_file
        @file_system.write path, contents
        reply "226 Transfer complete"
      end
    end

    def cmd_stou(argument)
      close_data_server_socket_when_done do
        ensure_logged_in
        ensure_file_system_supports :write
        path = argument || 'ftpd'
        path = File.expand_path(path, @name_prefix)
        path = unique_path(path)
        ensure_accessible path
        ensure_exists File.dirname(path)
        contents = receive_file(File.basename(path))
        @file_system.write path, contents
        reply "226 Transfer complete"
      end
    end

    def cmd_appe(argument)
      close_data_server_socket_when_done do
        ensure_logged_in
        ensure_file_system_supports :append
        path = argument
        syntax_error unless path
        path = File.expand_path(path, @name_prefix)
        ensure_accessible path
        contents = receive_file
        @file_system.append path, contents
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
        ensure_file_system_supports :dir
        ensure_file_system_supports :file_info
        path = list_path(argument)
        path = File.expand_path(path, @name_prefix)
        transmit_file(list(path), 'A')
      end
    end

    def cmd_nlst(argument)
      close_data_server_socket_when_done do
        ensure_logged_in
        ensure_file_system_supports :dir
        path = list_path(argument)
        path = File.expand_path(path, @name_prefix)
        transmit_file(name_list(path), 'A')
      end
    end

    def cmd_type(argument)
      ensure_logged_in
      syntax_error unless argument =~ /^(\S)(?: (\S+))?$/
      type_code = $1
      format_code = $2
      unless argument =~ /^([AEI]( [NTC])?|L .*)$/
        error '504 Invalid type code'
      end
      case argument
      when /^A( [NT])?$/
        @data_type = 'A'
      when /^(I|L 8)$/
        @data_type = 'I'
      else
        error '504 Type not implemented'
      end
      reply "200 Type set to #{@data_type}"
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
      ensure_not_epsv_all
      if @data_server
        reply "200 Already in passive mode"
      else
        interface = @socket.addr[3]
        @data_server = TCPServer.new(interface, 0)
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
      pwd 250
    end
    alias cmd_xcwd :cmd_cwd

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
      return if @logged_in
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

    def ensure_not_epsv_all
      if @epsv_all
        error "501 Not allowed after EPSV ALL"
      end
    end

    def tls_enabled?
      @config.tls != :off
    end

    def cmd_cdup(argument)
      syntax_error if argument
      ensure_logged_in
      cmd_cwd('..')
    end
    alias cmd_xcup :cmd_cdup

    def cmd_pwd(argument)
      ensure_logged_in
      pwd 257
    end
    alias cmd_xpwd :cmd_pwd

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
      expect 'rnto'
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

    def cmd_help(argument)
      if argument
        command = argument.upcase
        if supported_commands.include?(command)
          reply "214 Command #{command} is recognized"
        else
          reply "214 Command #{command} is not recognized"
        end
      else
        reply '214-The following commands are recognized:'
        supported_commands.sort.each_slice(8) do |commands|
          line = commands.map do |command|
            '   %-4s' % command
          end.join
          reply line
        end
        reply '214 Have a nice day.'
      end
    end

    def cmd_stat(argument)
      ensure_logged_in
      syntax_error if argument
      reply "211 #{server_name_and_version}"
    end

    def self.unimplemented(command)
      method_name = "cmd_#{command}"
      define_method method_name do |arguments|
        unimplemented_error
      end
      private method_name
    end

    def cmd_feat(argument)
      syntax_error if argument
      reply '211-Extensions supported:'
      extensions.each do |extension|
        reply " #{extension}"
      end
      reply '211 END'
    end

    def cmd_opts(argument)
      syntax_error unless argument
      error '501 Unsupported option'
    end

    def cmd_eprt(argument)
      ensure_logged_in
      ensure_not_epsv_all
      delim = argument[0..0]
      parts = argument.split(delim)[1..-1]
      syntax_error unless parts.size == 3
      protocol_code, address, port = *parts
      protocol_code = protocol_code.to_i
      ensure_protocol_supported protocol_code
      port = port.to_i
      set_active_mode_address address, port
      reply "200 EPRT command successful"
    end

    def ensure_protocol_supported(protocol_code)
      unless @protocols.supports_protocol?(protocol_code)
        protocol_list = @protocols.protocol_codes.join(',')
        error("522 Network protocol #{protocol_code} not supported, "\
              "use (#{protocol_list})")
      end
    end

    def cmd_epsv(argument)
      ensure_logged_in
      if @data_server
        reply "200 Already in passive mode"
      else
        if argument == 'ALL'
          @epsv_all = true
          reply "220 EPSV now required for port setup"
        else
          protocol_code = argument && argument.to_i
          if protocol_code
            ensure_protocol_supported protocol_code
          end
          interface = @socket.addr[3]
          @data_server = TCPServer.new(interface, 0)
          port = @data_server.addr[1]
          reply "229 Entering extended passive mode (|||#{port}|)"
        end
      end
    end

    def cmd_mdtm(path)
      ensure_logged_in
      ensure_file_system_supports :dir
      ensure_file_system_supports :file_info
      syntax_error unless path
      path = File.expand_path(path, @name_prefix)
      ensure_accessible(path)
      ensure_exists(path)
      info = @file_system.file_info(path)
      mtime = info.mtime.utc
      # We would like to report fractional seconds, too.  Sadly, the
      # spec declares that we may not report more precision than is
      # actually there, and there is no spec or API to tell us how
      # many fractional digits are significant.
      mtime = mtime.strftime("%Y%m%d%H%M%S")
      reply "213 #{mtime}"
    end

    def cmd_size(path)
      ensure_logged_in
      ensure_file_system_supports :read
      syntax_error unless path
      path = File.expand_path(path, @name_prefix)
      ensure_accessible(path)
      ensure_exists(path)
      contents = @file_system.read(path)
      contents = (@data_type == 'A') ? unix_to_nvt_ascii(contents) : contents
      reply "213 #{contents.bytesize}"
    end

    unimplemented :abor
    unimplemented :rein
    unimplemented :rest
    unimplemented :site
    unimplemented :smnt

    def extensions
      [
        (TLS_EXTENSIONS if tls_enabled?),
        IPV6_EXTENSIONS,
        RFC_3659_EXTENSIONS,
      ].flatten.compact
    end

    TLS_EXTENSIONS = [
      'AUTH TLS',
      'PBSZ',
      'PROT'
    ]

    IPV6_EXTENSIONS = [
      'EPRT',
      'EPSV',
    ]

    RFC_3659_EXTENSIONS = [
      'SIZE',
    ]

    def supported_commands
      private_methods.map do |method|
        method.to_s[/^cmd_(\w+)$/, 1]
      end.compact.map(&:upcase)
    end

    def pwd(status_code)
      reply %Q(#{status_code} "#{@name_prefix}" is current directory)
    end

    TRANSMISSION_MODES = {
      'B'=>['Block', false],
      'C'=>['Compressed', false],
      'S'=>['Stream', true],
    }

    FORMAT_TYPES = {
      'N'=>['Non-print', true],
      'T'=>['Telnet format effectors', true],
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

    def expect(command)
      @command_sequence_checker.expect command
    end

    def set_file_system(file_system)
      @file_system = FileSystemErrorTranslator.new(file_system)
    end

    def transmit_file(contents, data_type = @data_type)
      open_data_connection do |data_socket|
        contents = unix_to_nvt_ascii(contents) if data_type == 'A'
        handle_data_disconnect do
          data_socket.write(contents)
        end
        @config.log.debug "Sent #{contents.size} bytes"
        reply "226 Transfer complete"
      end
    end

    def receive_file(path_to_advertise = nil)
      open_data_connection(path_to_advertise) do |data_socket|
        contents = handle_data_disconnect do
          data_socket.read
        end
        contents = nvt_ascii_to_unix(contents) if @data_type == 'A'
        @config.log.debug "Received #{contents.size} bytes"
        contents
      end
    end

    def handle_data_disconnect
      return yield
    rescue Errno::ECONNRESET, Errno::EPIPE
      reply "426 Connection closed; transfer aborted."
    end

    def unix_to_nvt_ascii(s)
      return s if s =~ /\r\n/
      s.gsub(/\n/, "\r\n")
    end

    def nvt_ascii_to_unix(s)
      s.gsub(/\r\n/, "\n")
    end

    def open_data_connection(path_to_advertise = nil, &block)
      send_start_of_data_connection_reply(path_to_advertise)
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

    def send_start_of_data_connection_reply(path)
      if path
        reply "150 FILE: #{path}"
      else
        reply "150 Opening #{data_connection_description}"
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
      s = gets_with_timeout(@socket)
      throw :done if s.nil?
      s = s.chomp
      @config.log.debug s
      s
    end

    def gets_with_timeout(socket)
      ready = IO.select([@socket], nil, nil, @config.session_timeout)
      timeout if ready.nil?
      ready[0].first.gets
    end

    def timeout
      reply '421 Control connection timed out.'
      throw :done
    end

    def reply(s)
      if @config.response_delay.to_i != 0
        @config.log.warn "#{@config.response_delay} second delay before replying"
        sleep @config.response_delay
      end
      @config.log.debug s
      @socket.write s + "\r\n"
    end

    def unique_path(path)
      suffix = nil
      100.times do
        path_with_suffix = [path, suffix].compact.join('.')
        unless @file_system.exists?(path_with_suffix)
          return path_with_suffix
        end
        suffix = generate_suffix
      end
      raise "Unable to find unique path"
    end

    def generate_suffix
      set = ('a'..'z').to_a
      8.times.map do
        set[rand(set.size)]
      end.join
    end

    def init_command_sequence_checker
      checker = CommandSequenceChecker.new
      checker.must_expect 'acct'
      checker.must_expect 'pass'
      checker.must_expect 'rnto'
      checker
    end

    def list(path)
      format_list(path_list(path))
    end

    def format_list(paths)
      paths.map do |path|
        file_info = @file_system.file_info(path)
        @config.list_formatter.new(file_info).to_s + "\n"
      end.join
    end

    def name_list(path)
      path_list(path).map do |path|
        File.basename(path) + "\n"
      end.join
    end

    def path_list(path)
      if @file_system.directory?(path)
        path = File.join(path, '*')
      end
      @file_system.dir(path).sort
    end

    def authenticate(*args)
      while args.size < @config.driver.method(:authenticate).arity
        args << nil
      end
      @config.driver.authenticate(*args)
    end

    def login(*auth_tokens)
      unless authenticate(*auth_tokens)
        failed_auth
        error "530 Login incorrect"
      end
      reply "230 Logged in"
      set_file_system @config.driver.file_system(@user)
      @logged_in = true
      reset_failed_auths
    end

    def set_socket_options
      disable_nagle @socket
      receive_oob_data_inline @socket
    end

    def disable_nagle(socket)
      socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
    end

    def receive_oob_data_inline(socket)
      socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_OOBINLINE, 1)
    end

    def process_telnet_sequences(s)
      telnet = Telnet.new(s)
      unless telnet.reply.empty?
        @socket.write telnet.reply
      end
      telnet.plain
    end

    def reset_failed_auths
      @failed_auths = 0
    end

    def failed_auth
      @failed_auths += 1
      sleep @config.failed_login_delay
      if @config.max_failed_logins && @failed_auths >= @config.max_failed_logins
        reply "421 server unavailable"
        throw :done
      end
    end

    def set_data_address(n)

    end

    def set_active_mode_address(address, port)
      if port > 0xffff || port < 1024 && !@config.allow_low_data_ports
        error "504 Command not implemented for that parameter"
      end
      @data_hostname = address
      @data_port = port
    end

    def initialize_session
      @logged_in = false
      @data_type = 'A'
      @mode = 'S'
      @structure = 'F'
      @name_prefix = '/'
      @data_channel_protection_level = :clear
      @data_hostname = nil
      @data_port = nil
      @protection_buffer_size_set = false
      @epsv_all = false
      close_data_server_socket
      reset_failed_auths
    end

    def server_name_and_version
      "#{@config.server_name} #{@config.server_version}"
    end

  end
end
