module Ftpd

  class CmdRetr < CommandHandler

    def cmd_retr(argument)
      close_data_server_socket_when_done do
        ensure_logged_in
        ensure_file_system_supports :read
        path = argument
        syntax_error unless path
        path = File.expand_path(path, name_prefix)
        ensure_accessible path
        ensure_exists path
        contents = file_system.read(path)
        transmit_file contents
      end
    end

  end

end
