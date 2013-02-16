module Ftpd
  class DiskFileSystem

    def initialize(data_dir)
      @data_dir = data_dir
    end

    # Return true if the path is accessible to the user.  This will be
    # called for put, get and directory lists, so the path may not
    # exist.

    def accessible?(ftp_path)
      # The server should never try to access a path outside of the
      # directory (such as '../foo'), but if it does, we'll catch it
      # here.
      expand_ftp_path(ftp_path).start_with?(@data_dir)
    end

    # Return true if the file or directory path exists.

    def exists?(ftp_path)
      File.exists?(expand_ftp_path(ftp_path))
    end

    # Return true if the path exists and is a directory.

    def directory?(ftp_path)
      File.directory?(expand_ftp_path(ftp_path))
    end

    # Remove a file.  Can raise FileSystemError.

    def delete(ftp_path)
      handle_system_error do
        FileUtils.rm expand_ftp_path(ftp_path)
      end
    end

    # Read a file into memory.  Can raise FileSystemError.

    def read(ftp_path)
      handle_system_error do
        File.open(expand_ftp_path(ftp_path), 'rb', &:read)
      end
    end

    # Write a file to disk.  Can raise FileSystemError.

    def write(ftp_path, contents)
      handle_system_error do
        File.open(expand_ftp_path(ftp_path), 'wb') do |file|
          file.write contents
        end
      end
    end

    private

    def expand_ftp_path(ftp_path)
      File.expand_path(File.join(@data_dir, ftp_path))
    end

    def handle_system_error
      begin
        return yield
      rescue SystemCallError => e
        raise FileSystemError, e.message
      end
    end

  end
end
