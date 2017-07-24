# frozen_string_literal: true

require_relative 'command_handler'

module Ftpd

  class CmdNlst < CommandHandler

    def cmd_nlst(argument)
      close_data_server_socket_when_done do
        ensure_logged_in
        ensure_file_system_supports :dir
        path = list_path(argument)
        path = File.expand_path(path, name_prefix)
        transmit_file(StringIO.new(name_list(path)), 'A')
      end
    end

    private

    def name_list(target_path)
      path_list(target_path).map do |path|
        File.basename(path) + "\n"
      end.join
    end

  end

end
