module Ftpd
  class DiskFileSystem

    def initialize(data_dir)
      @data_dir = data_dir
    end

    def accessible?(ftp_path)
      expand_ftp_path(ftp_path).start_with?(@data_dir)
    end

    def exists?(ftp_path)
      File.exists?(expand_ftp_path(ftp_path))
    end

    def directory?(ftp_path)
      File.directory?(expand_ftp_path(ftp_path))
    end

    private

    def accessible_path?(ftp_path)
      expand_ftp_path(ftp_path) =~ /^#{@data_dir}/
    end

    def expand_ftp_path(ftp_path)
      File.expand_path(File.join(@data_dir, ftp_path))
    end

  end
end
