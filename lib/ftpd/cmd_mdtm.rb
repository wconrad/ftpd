# frozen_string_literal: true 

require_relative 'command_handler'

module Ftpd

  class CmdMdtm < CommandHandler

    def cmd_mdtm(path)
      ensure_logged_in
      ensure_file_system_supports :dir
      ensure_file_system_supports :file_info
      syntax_error unless path
      path = File.expand_path(path, name_prefix)
      ensure_accessible(path)
      ensure_exists(path)
      info = file_system.file_info(path)
      mtime = info.mtime.utc
      # We would like to report fractional seconds, too.  Sadly, the
      # spec declares that we may not report more precision than is
      # actually there, and there is no spec or API to tell us how
      # many fractional digits are significant.
      mtime = mtime.strftime("%Y%m%d%H%M%S")
      reply "213 #{mtime}"
    end

  end

end
