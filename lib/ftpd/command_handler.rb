require_relative 'error'
require_relative 'file_system_helper'

module Ftpd

  # Command handler base class
  
  class CommandHandler

    extend Forwardable

    include Error
    include FileSystemHelper

    COMMAND_FILENAME_PREFIX = 'cmd_'
    COMMAND_KLASS_PREFIX = 'Cmd'
    COMMAND_METHOD_PREFIX = 'cmd_'

    # param session [Session] The session

    def initialize(session)
      @session = session
    end

    # Return the commands implemented by this handler.  For example,
    # if the handler has the method "cmd_allo", this returns ['allo'].

    class << self
      include Memoizer
      def commands
        public_instance_methods.map(&:to_s).grep(/#{COMMAND_METHOD_PREFIX}/).map do |method|
          method.gsub(/^#{COMMAND_METHOD_PREFIX}/, '')
        end
      end
      memoize :commands
    end

    def_delegator 'self.class', :commands

    # Forward methods to the session

    def_delegators :@session,
    :close_data_server_socket_when_done,
    :command_not_needed,
    :config,
    :data_channel_protection_level=,
    :data_server,
    :data_server=,
    :data_type,
    :data_type=,
    :ensure_logged_in,
    :ensure_not_epsv_all,
    :ensure_protocol_supported,
    :ensure_tls_supported,
    :epsv_all=,
    :execute_command,
    :expect,
    :file_system,
    :list,
    :list_path,
    :logged_in,
    :logged_in=,
    :login,
    :mode=,
    :name_list,
    :name_prefix,
    :name_prefix=,
    :protection_buffer_size_set,
    :protection_buffer_size_set=,
    :pwd,
    :receive_file,
    :reply,
    :server_name_and_version,
    :set_active_mode_address,
    :socket,
    :structure=,
    :supported_commands,
    :syntax_error,
    :tls_enabled?,
    :transmit_file,
    :unix_to_nvt_ascii
 
  end

end
