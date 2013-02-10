require 'tempfile'

module Ftpd
  class TempDir

    attr_reader :path

    class << self

      def make(basename = nil)
        temp_dir = TempDir.new(basename)
        begin
          yield(temp_dir)
        ensure
          temp_dir.rm unless temp_dir.kept
        end
      end

    end

    attr_reader :kept

    def initialize(basename = nil)
      @path = unique_path(basename)
      @kept = false
      ObjectSpace.define_finalizer(self, TempDir.cleanup(path))
      Dir.mkdir(@path)
    end

    def keep
      @kept = true
      ObjectSpace.undefine_finalizer(self)
    end

    def rm
      keep
      system("rm -rf #{path.inspect}")
    end

    private

    def unique_path(basename)
      tempfile = Tempfile.new(File.basename(basename || $0 || ''))
      path = tempfile.path
      tempfile.close!
      path
    end

    def TempDir.cleanup(path)
      proc { |id|
        system("/bin/rm -rf #{path.inspect}")
      }
    end

  end
end
