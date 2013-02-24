module Ftpd

  # This class is a proxy file system driver that sends "450" replies
  # when the wrapped file system driver raises a FileSystemError.

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
    rescue FileSystemError => e
      error "450 #{e}"
    end

  end
end
