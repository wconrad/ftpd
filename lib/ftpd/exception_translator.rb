# frozen_string_literal: true

module Ftpd

  # Translate specific exceptions to FileSystemError.
  #
  # This is not intended to be used directly, but via the
  # TranslateExceptions module.

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
        raise PermanentFileSystemError, e.message
      end
    end

  end

end
