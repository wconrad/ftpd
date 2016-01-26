# frozen_string_literal: true

module Ftpd

  class CommandHandlerFactory

    def self.standard_command_handlers
      [
        CmdAbor,
        CmdAllo,
        CmdAppe,
        CmdAuth,
        CmdCdup,
        CmdCwd,
        CmdDele,
        CmdEprt,
        CmdEpsv,
        CmdFeat,
        CmdHelp,
        CmdList,
        CmdLogin,
        CmdMdtm,
        CmdMkd,
        CmdMode,
        CmdNlst,
        CmdNoop,
        CmdOpts,
        CmdPasv,
        CmdPbsz,
        CmdPort,
        CmdProt,
        CmdPwd,
        CmdQuit,
        CmdRein,
        CmdRename,
        CmdRest,
        CmdRetr,
        CmdRmd,
        CmdSite,
        CmdSize,
        CmdSmnt,
        CmdStat,
        CmdStor,
        CmdStou,
        CmdStru,
        CmdSyst,
        CmdType,
      ]      
    end

  end

end
