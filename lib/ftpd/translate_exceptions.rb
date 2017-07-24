# frozen_string_literal: true

module Ftpd

  # This module translates exceptions to FileSystemError exceptions.
  #
  # A disk file system (such as Ftpd::DiskFileSystem) is expected to
  # raise only FileSystemError exceptions, but many common operations
  # result in other exceptions such as SystemCallError.  This module
  # aids a disk driver in translating exceptions to FileSystemError
  # exceptions.
  #
  # In your file system, driver, include this module:
  #
  #     module MyDiskDriver
  #       include Ftpd::TranslateExceptions
  #
  # in your constructor, register the exceptions that should be translated:
  #
  #       def initialize
  #         translate_exception SystemCallError
  #       end
  #
  # And register methods for translation:
  #
  #       def read(ftp_path)
  #          ...
  #       end
  #       translate_exceptions :read

  module TranslateExceptions

    include Memoizer

    def self.included(includer)
      includer.extend ClassMethods
    end

    module ClassMethods

      # Cause the named method to translate exceptions.

      def translate_exceptions(method_name)
        original_method = instance_method(method_name)
        remove_method(method_name)
        define_method(method_name) do |*args, &block|
          exception_translator.translate_exceptions do
            original_method.bind(self).call(*args, &block)
          end
        end
      end

    end

    # Add exception class e to the list of exceptions to be
    # translated.

    def translate_exception(e)
      exception_translator.register_exception e
    end

    private

    def exception_translator
      ExceptionTranslator.new
    end
    memoize :exception_translator

  end

end
