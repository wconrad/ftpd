# frozen_string_literal: true

module Ftpd

  # Functions for manipulating LIST and NLST arguments

  module ListPath

    # Turn the argument to LIST/NLST into a path
    #
    # @param argument [String] The argument, or nil if not present
    # @return [String] The path
    #
    # Although compliant with the spec, this function does not do
    # these things that traditional Unix FTP servers do:
    #
    # * Allow multiple paths
    # * Handle switches such as "-a"
    #
    # See: http://cr.yp.to/ftp/list.html sections "LIST parameters"
    # and "LIST wildcards"

    def list_path(argument)
      argument ||= '.'
      argument = '' if argument =~ /^-/
      argument
    end

  end
end
