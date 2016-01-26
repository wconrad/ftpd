# frozen_string_literal: true

module Ftpd

  # Information about a file object (file, directory, symlink, etc.)

  class FileInfo

    # @return [String] The file's type, as returned by File.lstat
    # One of:
    # * 'file'
    # * 'directory'
    # * 'characterSpecial'
    # * 'blockSpecial'
    # * 'fifo'
    # * 'link'
    # * 'socket'
    # * 'unknown'

    attr_reader :ftype

    # @return [String] The group name

    attr_reader :group

    # @return [Integer] The mode bits, as returned by File::Stat#mode
    # The bits are:
    #   * 0 - others have execute permission
    #   * 1 - others have write permission
    #   * 2 - others have read permission
    #   * 3 - group has execute permission
    #   * 4 - group has write permission
    #   * 5 - group has read permission
    #   * 6 - owner has execute permission
    #   * 7 - owner has write permission
    #   * 8 - owner has read permission
    #   * 9 - sticky bit
    #   * 10 - set-group-ID bit
    #   * 11 - set UID bit
    # Other bits may be present; they are ignored

    attr_reader :mode

    # @return [Time] The modification time

    attr_reader :mtime

    # @return [Integer] The number of hard links

    attr_reader :nlink

    # @return [String] The owner name

    attr_reader :owner

    # @return [Integer] The size, in bytes

    attr_reader :size

    # @return [String] The object's path

    attr_reader :path

    # @return [String] The object's identifier
    #
    # This uniquely identifies the file: Two objects with the same
    # identifier are expected to refer to the same file or directory.
    #
    # On a disk file system, might be _dev_._inode_,
    # e.g. "8388621.48598"
    #
    # This is optional and does not have to be set.  If set, it is
    # used in EPLF output.

    attr_reader :identifier

    # Create a new instance.  See the various attributes for argument
    # details.
    #
    # @param opts [Hash] The file attributes
    # @option opts [String] :ftype The file type
    # @option opts [String] :group The group name
    # @option opts [String] :identifier The object's identifier
    # @option opts [Integer] :mode The mode bits
    # @option opts [Time] :mtime The modification time
    # @option opts [Integer] :nlink The number of hard links
    # @option opts [String] :owner The owner name
    # @option opts [Integer] :size The size
    # @option opts [String] :path The object's path

    def initialize(opts)
      @ftype = opts[:ftype]
      @group = opts[:group]
      @identifier = opts[:identifier]
      @mode = opts[:mode]
      @mtime = opts[:mtime]
      @nlink = opts[:nlink]
      @owner = opts[:owner]
      @path = opts[:path]
      @size = opts[:size]
    end

    # @return true if the object is a file

    def file?
      @ftype == 'file'
    end

    # @return true if the object is a directory

    def directory?
      @ftype == 'directory'
    end

  end

end
