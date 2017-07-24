# frozen_string_literal: true

require_relative 'translate_exceptions'

module Ftpd

  class DiskFileSystem

    # DiskFileSystem mixin for path expansion.  Used by every command
    # that accesses the disk file system.

    module PathExpansion

      # Set the data directory, the root of the disk file system.
      # data_dir should be an absolute path.

      def set_data_dir(data_dir)
        @data_dir = data_dir
      end

      # Expand an ftp_path to an absolute file system path.
      #
      # ftp_path is an absolute path relative to the FTP file system.
      # The return value is an absolute path relative to the disk file
      # system.

      def expand_ftp_path(ftp_path)
        File.expand_path(File.join(@data_dir, ftp_path))
      end

    end
  end

  class DiskFileSystem

    # DiskFileSystem mixin providing file attributes.  These are used,
    # alone or in combination, by nearly every command that accesses the
    # disk file system.

    module Accessors

      # Return true if the path is accessible to the user.  This will be
      # called for put, get and directory lists, so the file or
      # directory named by the path may not exist.
      # @param ftp_path [String] The virtual path
      # @return [Boolean]

      def accessible?(ftp_path)
        # The server should never try to access a path outside of the
        # directory (such as '../foo'), but if it does, we'll catch it
        # here.
        expand_ftp_path(ftp_path).start_with?(@data_dir)
      end

      # Return true if the file or directory path exists.
      # @param ftp_path [String] The virtual path
      # @return [Boolean]

      def exists?(ftp_path)
        File.exist?(expand_ftp_path(ftp_path))
      end

      # Return true if the path exists and is a directory.
      # @param ftp_path [String] The virtual path
      # @return [Boolean]

      def directory?(ftp_path)
        File.directory?(expand_ftp_path(ftp_path))
      end

    end
  end

  class DiskFileSystem

    # DiskFileSystem mixin for writing files.  Used by Append and Write.

    module FileWriting

      def write_file(ftp_path, stream, mode)
        File.open(expand_ftp_path(ftp_path), mode) do |file|
          while line = stream.read
            file.write line
          end
        end
      end

    end

  end

  class DiskFileSystem

    # DiskFileSystem mixin providing file deletion

    module Delete

      include TranslateExceptions

      # Remove a file.
      # @param ftp_path [String] The virtual path
      #
      # Called for:
      # * DELE
      #
      # If missing, then these commands are not supported.

      def delete(ftp_path)
        FileUtils.rm expand_ftp_path(ftp_path)
      end
      translate_exceptions :delete

    end
  end

  class DiskFileSystem

    # DiskFileSystem mixin providing file reading

    module Read

      include TranslateExceptions

      # Read a file from disk.
      # @param ftp_path [String] The virtual path
      # @yield [io] Passes an IO object to the block
      #
      # Called for:
      # * RETR
      #
      # If missing, then these commands are not supported.

      def read(ftp_path, &block)
        io = File.open(expand_ftp_path(ftp_path), 'rb')
        begin
          yield(io)
        ensure
          io.close
        end
      end
      translate_exceptions :read

    end
  end

  class DiskFileSystem

    # DiskFileSystem mixin providing file writing

    module Write

      include FileWriting
      include TranslateExceptions

      # Write a file to disk.
      # @param ftp_path [String] The virtual path
      # @param stream [Ftpd::Stream] Stream that contains the data to write
      #
      # Called for:
      # * STOR
      # * STOU
      #
      # If missing, then these commands are not supported.

      def write(ftp_path, stream)
        write_file ftp_path, stream, 'wb'
      end
      translate_exceptions :write

    end
  end

  class DiskFileSystem

    # DiskFileSystem mixin providing file appending

    module Append

      include FileWriting
      include TranslateExceptions

      # Append to a file.  If the file does not exist, create it.
      # @param ftp_path [String] The virtual path
      # @param stream [Ftpd::Stream] Stream that contains the data to write
      #
      # Called for:
      # * APPE
      #
      # If missing, then these commands are not supported.

      def append(ftp_path, stream)
        write_file ftp_path, stream, 'ab'
      end
      translate_exceptions :append

    end
  end

  class DiskFileSystem

    # DiskFileSystem mixing providing mkdir

    module Mkdir

      include TranslateExceptions

      # Create a directory.
      # @param ftp_path [String] The virtual path
      #
      # Called for:
      # * MKD
      #
      # If missing, then these commands are not supported.

      def mkdir(ftp_path)
        Dir.mkdir expand_ftp_path(ftp_path)
      end
      translate_exceptions :mkdir

    end

  end

  class DiskFileSystem

    # DiskFileSystem mixing providing mkdir

    module Rmdir

      include TranslateExceptions

      # Remove a directory.
      # @param ftp_path [String] The virtual path
      #
      # Called for:
      # * RMD
      #
      # If missing, then these commands are not supported.

      def rmdir(ftp_path)
        Dir.rmdir expand_ftp_path(ftp_path)
      end
      translate_exceptions :rmdir

    end

  end

  class DiskFileSystem

    # DiskFileSystem mixin providing directory listing

    module List

      include TranslateExceptions

      # Get information about a single file or directory.
      # @param ftp_path [String] The virtual path
      # @return [FileInfo]
      #
      # Should follow symlinks (per
      # {http://cr.yp.to/ftp/list/eplf.html}, "lstat() is not a good
      # idea for FTP directory listings").
      #
      # Called for:
      # * LIST
      #
      # If missing, then these commands are not supported.

      def file_info(ftp_path)
        stat = File.stat(expand_ftp_path(ftp_path))
        FileInfo.new(:ftype => stat.ftype,
                     :group => gid_name(stat.gid),
                     :identifier => identifier(stat),
                     :mode => stat.mode,
                     :mtime => stat.mtime,
                     :nlink => stat.nlink,
                     :owner => uid_name(stat.uid),
                     :path => ftp_path,
                     :size => stat.size)
      end
      translate_exceptions :file_info

      # Expand a path that may contain globs into a list of paths of
      # matching files and directories.
      # @param ftp_path [String] The virtual path
      # @return [Array<String>]
      #
      # The paths returned are fully qualified, relative to the root
      # of the virtual file system.
      # 
      # For example, suppose these files exist on the physical file
      # system:
      #
      #   /var/lib/ftp/foo/foo
      #   /var/lib/ftp/foo/subdir/bar
      #   /var/lib/ftp/foo/subdir/baz
      #
      # and that the directory /var/lib/ftp is the root of the virtual
      # file system.  Then:
      #
      #   dir('foo')         # => ['/foo']
      #   dir('subdir')      # => ['/subdir']
      #   dir('subdir/*')    # => ['/subdir/bar', '/subdir/baz']
      #   dir('*')           # => ['/foo', '/subdir']
      #
      # Called for:
      # * LIST
      # * NLST
      #
      # If missing, then these commands are not supported.

      def dir(ftp_path)
        Dir[expand_ftp_path(ftp_path)].map do |path|
          path.sub(/^#{@data_dir}/, '')
        end
      end
      translate_exceptions :dir

      private

      def uid_name(uid)
        Etc.getpwuid(uid).name
      end

      def gid_name(gid)
        Etc.getgrgid(gid).name
      end

      def identifier(stat)
        [stat.dev, stat.ino].join('.')
      end

    end
  end

  class DiskFileSystem

    # DiskFileSystem mixin providing file/directory rename/move

    module Rename

      include TranslateExceptions

      # Rename or move a file or directory
      #
      # Called for:
      # * RNTO
      #
      # If missing, then these commands are not supported.

      def rename(from_ftp_path, to_ftp_path)
        FileUtils.mv(expand_ftp_path(from_ftp_path),
                     expand_ftp_path(to_ftp_path))
      end
      translate_exceptions :rename

    end
  end

  class DiskFileSystem

    # DiskFileSystem "omnibus" mixin, which pulls in mixins which are
    # likely to be needed by any DiskFileSystem.

    module Base
      include TranslateExceptions
      include DiskFileSystem::Accessors
      include DiskFileSystem::PathExpansion
    end

  end

  # An FTP file system mapped to a disk directory.  This can serve as
  # a template for creating your own specialized driver.
  #
  # Any method may raise a PermanentFileSystemError (e.g. "file not
  # found") or TransientFileSystemError (e.g. "file busy").  A
  # PermanentFileSystemError will cause a "550" error response to be
  # sent; a TransientFileSystemError will cause a "450" error response
  # to be sent. Methods may also raise an FtpServerError with any
  # desired error code.
  #
  # The class is divided into modules that may be included piecemeal.
  # By including some mixins and not others, you can compose a disk
  # file system driver "a la carte."  This is useful if you want an
  # FTP server that, for example, allows reading but not writing
  # files.

  class DiskFileSystem

    include DiskFileSystem::Base

    # Mixins that make available commands or groups of commands.  Each
    # can be safely left out with the only effect being to make One or
    # more commands be unimplemented.

    include DiskFileSystem::Append
    include DiskFileSystem::Delete
    include DiskFileSystem::List
    include DiskFileSystem::Mkdir
    include DiskFileSystem::Read
    include DiskFileSystem::Rename
    include DiskFileSystem::Rmdir
    include DiskFileSystem::Write

    # Make a new instance to serve a directory.  data_dir should be an
    # absolute path.

    def initialize(data_dir)
      set_data_dir data_dir
      translate_exception SystemCallError
    end

  end

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
