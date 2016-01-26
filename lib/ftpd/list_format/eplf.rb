# frozen_string_literal: true

module Ftpd
  module ListFormat

    # Easily Parsed LIST Format (EPLF) Directory formatter
    # See: {http://cr.yp.to/ftp/list/eplf.html}

    class Eplf

      extend Forwardable

      # Create a new formatter for a file object
      # @param file_info [FileInfo]

      def initialize(file_info)
        @file_info = file_info
      end

      # Return the formatted directory entry.
      # For example:
      #   +i8388621.48598,m824253270,r,s612, 514.html
      # Note: The calling code adds the \r\n

      def to_s
        "+%s\t%s" % [facts, filename]
      end

      private

      def facts
        [
          retrievable_fact,
          cwd_target_fact,
          size_fact,
          mtime_fact,
          identifier_fact,
        ].compact.join(',')
      end

      def retrievable_fact
        'r' if retrievable?
      end

      def cwd_target_fact
        '/' if cwd_target?
      end

      def size_fact
        "s#{@file_info.size}" if retrievable?
      end

      def mtime_fact
        "m#{@file_info.mtime.to_i}"
      end

      def identifier_fact
        "i#{@file_info.identifier}" if @file_info.identifier
      end

      def filename
        File.basename(@file_info.path)
      end

      def retrievable?
        @file_info.file?
      end

      def cwd_target?
        @file_info.directory?
      end

    end

  end
end
