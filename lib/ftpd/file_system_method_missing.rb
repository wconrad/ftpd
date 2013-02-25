module Ftpd

  # A proxy file system driver that sends "502 Command not
  # implemented" replies when the wrapped file system driver is
  # missing a method.

  class FileSystemMethodMissing

    include Error

    def initialize(file_system)
      @file_system = file_system
    end

    def respond_to?(method)
      @file_system.respond_to?(method) || super
    end

    def method_missing(method, *args)
      if @file_system.respond_to?(method)
        @file_system.send(method, *args)
      else
        unimplemented_error
      end
    end

  end
end
