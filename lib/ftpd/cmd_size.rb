require_relative 'command_handler'

module Ftpd

  class CmdSize < CommandHandler

    include AsciiHelper

    def cmd_size(path)
      ensure_logged_in
      ensure_file_system_supports :read
      syntax_error unless path
      path = File.expand_path(path, name_prefix)
      ensure_accessible(path)
      ensure_exists(path)

      file_system.read(path) do |file|
        if data_type == 'A'
          size = 0
          while line = file.gets
            size += unix_to_nvt_ascii(line).size
          end
        else
          size = file.size
        end

        reply "213 #{size}"
      end
    end

  end

end
