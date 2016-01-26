# frozen_string_literal: true

module Ftpd

  # This mixin provides an insecure SSL certificate.  This certificate
  # should only be used for testing.

  module InsecureCertificate

    # The path of an insecure SSL certificate.

    def insecure_certfile_path
      File.expand_path('../../insecure-test-cert.pem',
                       File.dirname(__FILE__))
    end

  end
end
