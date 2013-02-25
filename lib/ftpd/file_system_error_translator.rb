module Ftpd

  # A proxy file system driver that sends a "450" or "550" error
  # reply in response to FileSystemError exceptions.

  class FileSystemErrorTranslator

    include Error

    def initialize(file_system)
      @file_system = file_system
    end

    def respond_to?(method)
      @file_system.respond_to?(method) || super
    end

    def method_missing(method, *args)
      @file_system.send(method, *args)
    rescue PermanentFileSystemError => e
      permanent_error e
    rescue TransientFileSystemError => e
      transient_error e
    rescue FileSystemError => e
      permanent_error e
    end

  end
end
