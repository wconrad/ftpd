module Ftpd

  # This module provides an easy interface to ExceptionTranslator.

  module TranslateExceptions

    include Memoizer

    def self.included(includer)
      includer.extend ClassMethods
    end

    module ClassMethods

      # Cause the named method to translate exceptions.

      def translate_exceptions(method_name)
        original_method = instance_method(method_name)
        define_method method_name do |*args|
          exception_translator.translate_exceptions do
            original_method.bind(self).call *args
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
