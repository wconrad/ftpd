require_relative 'command_handler'

module Ftpd

  class CmdSize < CommandHandler

    def cmd_size(path)
      ensure_logged_in
      ensure_file_system_supports :read
      syntax_error unless path
      path = File.expand_path(path, name_prefix)
      ensure_accessible(path)
      ensure_exists(path)
      contents = file_system.read(path)
      contents = (data_type == 'A') ? unix_to_nvt_ascii(contents) : contents
      reply "213 #{contents.bytesize}"
    end

  end

end
