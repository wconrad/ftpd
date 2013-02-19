module Ftpd

  # Translate specific exceptions to FileSystemError.

  class ExceptionTranslator

    def initialize
      @exceptions = []
    end

    # Register an exception class.

    def register_exception(e)
      @exceptions << e
    end

    # Run a block, translating specific exceptions to FileSystemError.

    def translate_exceptions
      begin
        return yield
      rescue *@exceptions => e
        raise FileSystemError, e.message
      end
    end

  end

end
