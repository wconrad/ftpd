module Ftpd
  class Session

    include Error
    include ListPath

    attr_accessor :data_server
    attr_accessor :data_type
    attr_accessor :logged_in
    attr_accessor :name_prefix
    attr_accessor :protection_buffer_size_set
    attr_accessor :socket
    attr_reader :config
    attr_reader :file_system
    attr_writer :data_channel_protection_level
    attr_writer :epsv_all
    attr_writer :mode
    attr_writer :structure

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
      @command_handlers = CommandHandlers.new
      register_commands
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
              unless valid_command?(command)
                unrecognized_error s
              end
              @command_sequence_checker.check command
              execute_command command, argument
            rescue CommandError => e
              reply e.message
            end
          end
        rescue Errno::ECONNRESET, Errno::EPIPE
        end
      end
    end

    private

    def register_commands
      [
        CmdAbor,
        CmdAllo,
        CmdAppe,
        CmdAuth,
        CmdCdup,
        CmdCwd,
        CmdDele,
        CmdEprt,
        CmdEpsv,
        CmdFeat,
        CmdHelp,
        CmdList,
        CmdLogin,
        CmdMdtm,
        CmdMkd,
        CmdMode,
        CmdNlst,
        CmdNoop,
        CmdOpts,
        CmdPasv,
        CmdPbsz,
        CmdPort,
        CmdProt,
        CmdPwd,
        CmdQuit,
        CmdRein,
        CmdRename,
        CmdRest,
        CmdRetr,
        CmdRmd,
        CmdSite,
        CmdSize,
        CmdSmnt,
        CmdStat,
        CmdStor,
        CmdStou,
        CmdStru,
        CmdSyst,
        CmdType,
      ].each do |klass|
        @command_handlers << klass.new(self)
      end
    end

    def valid_command?(command)
      @command_handlers.has?(command)
    end

    def execute_command command, argument
      @command_handlers.execute command, argument
    end

    def syntax_error
      error "501 Syntax error"
    end

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

    def ensure_protocol_supported(protocol_code)
      unless @protocols.supports_protocol?(protocol_code)
        protocol_list = @protocols.protocol_codes.join(',')
        error("522 Network protocol #{protocol_code} not supported, "\
              "use (#{protocol_list})")
      end
    end

    def supported_commands
      @command_handlers.commands.map(&:upcase)
    end

    def pwd(status_code)
      reply %Q(#{status_code} "#{@name_prefix}" is current directory)
    end

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
      user = auth_tokens.first
      unless authenticate(*auth_tokens)
        failed_auth
        error "530 Login incorrect"
      end
      reply "230 Logged in"
      set_file_system @config.driver.file_system(user)
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
