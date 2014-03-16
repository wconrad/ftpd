module Ftpd

  class CmdAppe < CommandHandler

    def cmd_appe(argument)
      close_data_server_socket_when_done do
        ensure_logged_in
        ensure_file_system_supports :append
        path = argument
        syntax_error unless path
        path = File.expand_path(path, name_prefix)
        ensure_accessible path
        contents = receive_file
        file_system.append path, contents
        reply "226 Transfer complete"
      end
    end

  end

end
