# frozen_string_literal: true

module Ftpd

  # Create temporary directories that will be removed when the program
  # exits.

  module TempDir

    # Create a temporary directory, returning its path.  When the
    # program exists, the directory (and its contents) are removed.

    def make
      Dir.mktmpdir.tap do |path|
        at_exit do
          FileUtils.rm_rf path
          Dir.rmdir(path) if File.exist?(path)
        end
      end
    end
    module_function :make

  end
end
