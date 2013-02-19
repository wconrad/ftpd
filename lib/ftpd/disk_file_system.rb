module Ftpd

  # An FTP file system mapped to a disk directory.  This can serve as
  # a template for creating your own specialized driver.
  #
  # Some methods may raise FileSystemError; some may not.  The
  # predicates (methods ending with a question mark) may not; other
  # methods may.  FileSystemError is the _only_ exception which a file
  # system driver may raise.

  class DiskFileSystem

    include TranslateExceptions

    # Make a new instance to serve a directory.  data_dir should be
    # fully qualified.

    def initialize(data_dir)
      @data_dir = data_dir
      translate_exception SystemCallError
    end

    # Return true if the path is accessible to the user.  This will be
    # called for put, get and directory lists, so the file or
    # directory named by the path may not exist.

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
      FileUtils.rm expand_ftp_path(ftp_path)
    end
    translate_exceptions :delete

    # Read a file into memory.  Can raise FileSystemError.

    def read(ftp_path)
      File.open(expand_ftp_path(ftp_path), 'rb', &:read)
    end
    translate_exceptions :read

    # Write a file to disk.  Can raise FileSystemError.

    def write(ftp_path, contents)
      File.open(expand_ftp_path(ftp_path), 'wb') do |file|
        file.write contents
      end
    end
    translate_exceptions :write

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

    def list_long(ftp_path)
      ls(ftp_path, '-l')
    end

    # Get a file list, short form.  Can raise FileSystemError.
    #
    # This returns one filename per line, and nothing else

    def list_short(ftp_path)
      ls(ftp_path, '-1')
    end

    private

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

    def expand_ftp_path(ftp_path)
      File.expand_path(File.join(@data_dir, ftp_path))
    end

  end
end
