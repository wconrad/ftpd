# frozen_string_literal: true

module Ftpd

  class CommandLoop

    extend Forwardable

    include Error

    def initialize(session)
      @session = session
    end

    def read_and_execute_commands
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
                error "Syntax error, command unrecognized: #{s.chomp}", 500
              end
              command_sequence_checker.check command
              execute_command command, argument
            rescue FtpServerError => e
              reply e.message_with_code
            rescue => e
              reply "451 Requested action aborted. Local error in processing."
              config.exception_handler.call(e) unless config.exception_handler.nil?
            end
          end
        rescue Errno::ECONNRESET, Errno::EPIPE
        end
      end
    end

    private

    def_delegators :@session,
    :command_sequence_checker,
    :config,
    :execute_command,
    :reply,
    :server_name_and_version,
    :socket,
    :valid_command?

    def get_command
      s = gets_with_timeout(socket)
      throw :done if s.nil?
      s = s.chomp
      config.log.debug s.sub(/^PASS .*/, 'PASS **FILTERED**') # Filter real password
      s
    end
    
    def gets_with_timeout(socket)
      ready = IO.select([socket], nil, nil, config.session_timeout)
      timeout if ready.nil?
      ready[0].first.gets
    end

    def timeout
      reply '421 Control connection timed out.'
      throw :done
    end

    def process_telnet_sequences(s)
      telnet = Telnet.new(s)
      unless telnet.reply.empty?
        socket.write telnet.reply
      end
      telnet.plain
    end

  end

end
