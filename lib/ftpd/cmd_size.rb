# frozen_string_literal: true

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
      file_system.read(path) do |file|
        if data_type == 'A'
          output = StringIO.new
          io = Ftpd::Stream.new(output, data_type)
          io.write(file)
          size = output.size
        else
          size = file.size
        end
        reply "213 #{size}"
      end
    end

  end

end
