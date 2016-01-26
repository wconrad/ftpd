# frozen_string_literal: true

module Ftpd

  # A disk file system that does not allow any modification (writes,
  # deletes, etc.)

  class ReadOnlyDiskFileSystem

    include DiskFileSystem::Base
    include DiskFileSystem::List
    include DiskFileSystem::Read

    # Make a new instance to serve a directory.  data_dir should be an
    # absolute path.

    def initialize(data_dir)
      set_data_dir data_dir
      translate_exception SystemCallError
    end

  end

end
