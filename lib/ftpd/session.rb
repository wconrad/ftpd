# frozen_string_literal: true

module Ftpd
  class Session

    include Error
    include ListPath

    attr_accessor :command_sequence_checker
    attr_accessor :data_channel_protection_level
    attr_accessor :data_server
    attr_accessor :data_server_factory
    attr_accessor :data_type
    attr_accessor :logged_in
    attr_accessor :name_prefix
    attr_accessor :protection_buffer_size_set
    attr_accessor :socket
    attr_reader :config
    attr_reader :data_hostname
    attr_reader :data_port
    attr_reader :file_system
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
      @command_loop = CommandLoop.new(self)
      @data_server_factory = DataServerFactory.make(
        @socket.addr[3],
        config.passive_ports,
      )
      register_commands
      initialize_session
    end

    def run
      @command_loop.read_and_execute_commands
    end

    def valid_command?(command)
      @command_handlers.has?(command)
    end
    
    def execute_command command, argument
      @command_handlers.execute command, argument
    end
    
    def ensure_logged_in
      return if @logged_in
      error "Not logged in", 530
    end
    
    def ensure_tls_supported
      unless tls_enabled?
        error "TLS not enabled", 534
      end
    end
    
    def ensure_not_epsv_all
      if @epsv_all
        error "Not allowed after EPSV ALL", 501
      end
    end
    
    def tls_enabled?
      @config.tls != :off
    end
    
    def ensure_protocol_supported(protocol_code)
      unless @protocols.supports_protocol?(protocol_code)
        protocol_list = @protocols.protocol_codes.join(',')
        error("Network protocol #{protocol_code} not supported, "\
              "use (#{protocol_list})", 522)
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

    def command_not_needed
      reply '202 Command not needed at this site'
    end
    
    def close_data_server_socket
      return unless @data_server
      @data_server.close
      @data_server = nil
    end
    
    def reply(s)
      if @config.response_delay.to_i != 0
        @config.log.warn "#{@config.response_delay} second delay before replying"
        sleep @config.response_delay
      end
      @config.log.debug s
      @socket.write s + "\r\n"
    end

    def login(*auth_tokens)
      user = auth_tokens.first
      unless authenticate(*auth_tokens)
        failed_auth
        error "Login incorrect", 530
      end
      reply "230 Logged in"
      set_file_system @config.driver.file_system(user)
      @logged_in = true
      reset_failed_auths
    end

    def set_active_mode_address(address, port)
      if port > 0xffff || port < 1024 && !@config.allow_low_data_ports
        error "Command not implemented for that parameter", 504
      end
      @data_hostname = address
      @data_port = port
    end

    def server_name_and_version
      "#{@config.server_name} #{@config.server_version}"
    end

    private

    def register_commands
      handlers = CommandHandlerFactory.standard_command_handlers
      handlers.each do |klass|
        @command_handlers << klass.new(self)
      end
    end
    
    def set_file_system(file_system)
      @file_system = file_system
    end
    
    def init_command_sequence_checker
      checker = CommandSequenceChecker.new
      checker.must_expect 'acct'
      checker.must_expect 'pass'
      checker.must_expect 'rnto'
      checker
    end

    def authenticate(*args)
      while args.size < @config.driver.method(:authenticate).arity
        args << nil
      end
      @config.driver.authenticate(*args)
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
    
  end
end
