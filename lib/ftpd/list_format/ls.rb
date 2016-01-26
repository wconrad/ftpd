# frozen_string_literal: true

module Ftpd
  module ListFormat

    # Directory formatter that approximates the output of "ls -l"

    class Ls

      extend Forwardable

      # Create a new formatter for a file object
      # @param file_info [FileInfo]

      def initialize(file_info)
        @file_info = file_info
      end

      # Return the formatted directory entry, for example:
      #   -rw-r--r-- 1 user     group    Mar  3 08:38 foo

      def to_s
        '%s%s %d %-8s %-8s %8d %s %s' % [
          file_type,
          file_mode_letters,
          @file_info.nlink,
          @file_info.owner,
          @file_info.group,
          @file_info.size,
          format_time(@file_info.mtime),
          filename,
        ]
      end

      private

      SIX_MONTHS = 180 * 24 * 60 * 60

      def filename
        File.basename(@file_info.path)
      end

      def file_type
        FileType.letter(@file_info.ftype)
      end

      def file_mode_letters
        FileMode.new(@file_info.mode).letters
      end

      def self.format_time(mtime)
        age = Time.now - mtime
        format = '%b %e ' + if age < 0 || age > SIX_MONTHS
                              ' %Y'
                            else
                              '%H:%M'
                            end
        mtime.strftime(format)
      end
      def_delegator self, :format_time

      # Map file type strings to ls file type letters

      class FileType

        # Map a file type string to a file type letter.
        # @param ftype [String] file type as returned by File::Stat#ftype
        # @return [String] File type letter

        def self.letter(ftype)
          case ftype
          when 'file'
            '-'
          when 'directory'
            'd'
          when 'characterSpecial'
            'c'
          when 'blockSpecial'
            'b'
          when 'fifo'
            'p'
          when 'link'
            'l'
          when 'socket'
            's'
          else  # 'unknown', etc.
            '?'
          end
        end

      end

      # Map file mode bits into ls style file mode letters

      class FileMode

        # @param mode [Integer] File mode bits, as returned by
        #   File::Stat#mode

        def initialize(mode)
          @mode = mode
        end

        # Return the mode bits as ls style letters.
        # For example, "-rw-r--r--"

        def letters
          [
            triad(OWNER_READ, OWNER_WRITE, OWNER_EXECUTE, SET_UID, 'Ss'),
            triad(GROUP_READ, GROUP_WRITE, GROUP_EXECUTE, SET_GID, 'Ss'),
            triad(OTHER_READ, OTHER_WRITE, OTHER_EXECUTE, STICKY, 'Tt'),
          ].join
        end

        private

        def bit(bit_number)
          @mode >> bit_number & 1
        end

        def triad(read_bit, write_bit, execute_bit, special_bit, special_letters)
          execute_chars = if bit(special_bit) != 0
                            special_letters
                          else
                            '-x'
                          end
          [
            pick_char('-r', read_bit),
            pick_char('-w', write_bit),
            pick_char(execute_chars, execute_bit),
          ]
        end

        def pick_char(s, bit_number)
          s[bit(bit_number), 1]
        end

        OTHER_EXECUTE = 0
        OTHER_WRITE = 1
        OTHER_READ = 2
        GROUP_EXECUTE = 3
        GROUP_WRITE = 4
        GROUP_READ = 5
        OWNER_EXECUTE = 6
        OWNER_WRITE = 7
        OWNER_READ = 8
        STICKY = 9
        SET_GID = 10
        SET_UID = 11

      end

    end

  end
end
