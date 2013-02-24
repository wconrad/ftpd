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
      # @data_dir is an absolute path relative to the disk file system.
      # The return value is an absolute path relative to the disk file system.

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
      #
      # Called for:
      # * STOR
      # * RETR
      # * DELE
      # * CWD
      # * MKD

      def accessible?(ftp_path)
        # The server should never try to access a path outside of the
        # directory (such as '../foo'), but if it does, we'll catch it
        # here.
        expand_ftp_path(ftp_path).start_with?(@data_dir)
      end

      # Return true if the file or directory path exists.
      #
      # Called for:
      # * STOR (with directory)
      # * RETR
      # * DELE
      # * CWD
      # * MKD

      def exists?(ftp_path)
        File.exists?(expand_ftp_path(ftp_path))
      end

      # Return true if the path exists and is a directory.
      #
      # Called for:
      # * CWD
      # * MKD

      def directory?(ftp_path)
        File.directory?(expand_ftp_path(ftp_path))
      end

    end
  end

  class DiskFileSystem

    # DiskFileSystem mixin providing file deletion

    module Delete

      include TranslateExceptions

      # Remove a file.  Can raise FileSystemError.
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

      # Read a file into memory.  Can raise FileSystemError.
      #
      # Called for:
      # * RETR
      #
      # If missing, then these commands are not supported.

      def read(ftp_path)
        File.open(expand_ftp_path(ftp_path), 'rb', &:read)
      end
      translate_exceptions :read

    end
  end

  class DiskFileSystem

    # DiskFileSystem mixin providing file writing

    module Write

      include TranslateExceptions

      # Write a file to disk.  Can raise FileSystemError.
      #
      # Called for:
      # * STOR
      #
      # If missing, then these commands are not supported.

      def write(ftp_path, contents)
        File.open(expand_ftp_path(ftp_path), 'wb') do |file|
          file.write contents
        end
      end
      translate_exceptions :write

    end
  end

  class DiskFileSystem

    # DiskFileSystem mixing providing mkdir

    module Mkdir

      include TranslateExceptions

      # Create a directory.  Can raise FileSystemError.
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

    # Ls interface used by List and NameList

    module Ls

      def ls(ftp_path, option)
        path = expand_ftp_path(ftp_path)
        dirname = File.dirname(path)
        filename = File.basename(path)
        command = [
          'ls',
          option,
          filename,
          '2>&1',
        ].compact.join(' ')
        if File.exists?(dirname)
          list = Dir.chdir(dirname) do
            `#{command}`
          end
        else
          list = ''
        end
        list = "" if $? != 0
        list = list.gsub(/^total \d+\n/, '')
      end

    end

  end

  class DiskFileSystem

    # DiskFileSystem mixin providing directory listing

    module List

      include TranslateExceptions

      # Get a file list, long form.  Can raise FileSystemError.  This
      # returns a long-form directory listing.  The FTP standard does
      # not specify the format of the listing, but many systems emit a
      # *nix style directory listing:
      #
      #     -rw-r--r-- 1 wayne wayne 4 Feb 18 18:36 a
      #     -rw-r--r-- 1 wayne wayne 8 Feb 18 18:36 b
      #
      # some emit a Windows style listing.  Some emit EPLF (Easily
      # Parsed List Format):
      #
      #     +i8388621.48594,m825718503,r,s280, djb.html
      #     +i8388621.50690,m824255907,/, 514
      #     +i8388621.48598,m824253270,r,s612, 514.html
      #
      # EPLF is a draft internet standard for the output of LIST:
      #
      #     http://cr.yp.to/ftp/list/eplf.html
      #
      # Some FTP clients know how to parse EPLF; those clients will
      # display the EPLF in a more user-friendly format.  Clients that
      # don't recognize EPLF will display it raw.  The advantages of
      # EPLF are that it's easier for clients to parse, and the client
      # can display the LIST output in any format it likes.
      #
      # This class emits a *nix style listing.  It does so by shelling
      # to the "ls" command, so it won't run on Windows at all.
      #
      # Called for:
      # * LIST
      #
      # If missing, then these commands are not supported.

      def list(ftp_path)
        ls(ftp_path, '-l')
      end

    end
  end

  class DiskFileSystem

    # DiskFileSystem mixin providing directory name listing

    module NameList

      include Ls

      # Get a file list, short form.  Can raise FileSystemError.
      #
      # This returns one filename per line, and nothing else
      #
      # Called for:
      # * NLST
      #
      # If missing, then these commands are not supported.

      def name_list(ftp_path)
        ls(ftp_path, '-1')
      end

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
  # Some methods may raise FileSystemError; some may not.  The
  # predicates (methods ending with a question mark) may not; other
  # methods may.  FileSystemError is the _only_ exception which a file
  # system driver may raise.
  #
  # The class is divided into modules that may be included piecemeal.
  # By including some mixins and not others, you can compose a disk
  # file system driver "a la cart."  This is useful if you want an FTP
  # server that, for example, allows reading but not writing files.

  class DiskFileSystem

    include DiskFileSystem::Base

    # Mixins that make available commands or groups of commands.  Each
    # can be safely left out with the only effect being to make One or
    # more commands be unimplemented.

    include DiskFileSystem::Delete
    include DiskFileSystem::List
    include DiskFileSystem::Mkdir
    include DiskFileSystem::NameList
    include DiskFileSystem::Read
    include DiskFileSystem::Write

    # Make a new instance to serve a directory.  data_dir should be an
    # absolute path.

    def initialize(data_dir)
      set_data_dir data_dir
      translate_exception SystemCallError
    end

  end
end
