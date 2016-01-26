# frozen_string_literal: true

module Ftpd

  class Stream

    CHUNK_SIZE = 1024 * 100 # 100kb

    attr_reader :data_type
    attr_reader :byte_count

    # @param io [IO] The stream to read from or write to
    # @param data_type [String] The FTP data type of the stream

    def initialize(io, data_type)
      @io, @data_type = io, data_type
      @byte_count = 0
    end

    # Read and convert a chunk of up to CHUNK_SIZE from the stream
    # @return [String] if any bytes remain to read from the stream
    # @return [NilClass] if no bytes remain

    def read
      chunk = converted_chunk(@io)
      return unless chunk
      chunk = nvt_ascii_to_unix(chunk) if data_type == 'A'
      record_bytes(chunk)
      chunk
    end

    # Convert and write a chunk of up to CHUNK_SIZE to the stream from the
    # provided IO object
    #
    # @param io [IO] The data to be written to the stream

    def write(io)
      while chunk = converted_chunk(io)
        chunk = unix_to_nvt_ascii(chunk) if data_type == 'A'
        result = @io.write(chunk)
        record_bytes(chunk)
        result
      end
    end

    private

    # We never want to break up any \r\n sequences in the file. To avoid
    # this in an efficient way, we always pull an "extra" character from the
    # stream and add it to the buffer. If the character is a \r, then we put
    # it back onto the stream instead of adding it to the buffer.

    def converted_chunk(io)
      chunk = io.read(CHUNK_SIZE)
      return unless chunk
      if data_type == 'A'
        next_char = io.getc
        if next_char == "\r"
          io.ungetc(next_char)
        elsif next_char
          chunk += next_char
        end
      end
      chunk
    end

    def unix_to_nvt_ascii(s)
      return s if s =~ /\r\n/
      s.gsub(/\n/, "\r\n")
    end

    def nvt_ascii_to_unix(s)
      s.gsub(/\r\n/, "\n")
    end

    def record_bytes(chunk)
      @byte_count += chunk.size if chunk
    end

  end

end
