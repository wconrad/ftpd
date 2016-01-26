# frozen_string_literal: true

require_relative 'command_handler'

module Ftpd

  class CmdProt < CommandHandler

    def cmd_prot(level_arg)
      level_code = level_arg.upcase
      unless protection_buffer_size_set
        error "PROT must be preceded by PBSZ", 503
      end
      level = DATA_CHANNEL_PROTECTION_LEVELS[level_code]
      unless level
        error "Unknown protection level", 504
      end
      unless level == :private
        error "Unsupported protection level #{level}", 536
      end
      self.data_channel_protection_level = level
      reply "200 Data protection level #{level_code}"
    end

    private

    DATA_CHANNEL_PROTECTION_LEVELS = {
      'C'=>:clear,
      'S'=>:safe,
      'E'=>:confidential,
      'P'=>:private
    }

  end

end
