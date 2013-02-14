module Ftpd
  class FileSystemErrorTranslator

    include Error

    def initialize(file_system)
      @file_system = file_system
    end

    def respond_to?(method)
      @file_system.respond_to?(method)
    end

    def method_missing(method, *args)
      @file_system.send(method, *args)
    rescue FileSystemError => e
      error "450 #{e}"
    end

  end
end
