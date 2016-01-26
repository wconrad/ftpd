# frozen_string_literal: true

require_relative 'command_handler'

module Ftpd

  class CmdList < CommandHandler

    def cmd_list(argument)
      close_data_server_socket_when_done do
        ensure_logged_in
        ensure_file_system_supports :dir
        ensure_file_system_supports :file_info
        path = list_path(argument)
        path = File.expand_path(path, name_prefix)
        transmit_file(StringIO.new(list(path)), 'A')
      end
    end

    private

    def list(path)
      format_list(path_list(path))
    end

    def format_list(paths)
      paths.map do |path|
        file_info = file_system.file_info(path)
        config.list_formatter.new(file_info).to_s + "\n"
      end.join
    end

  end

end
