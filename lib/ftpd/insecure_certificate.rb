module Ftpd
  module InsecureCertificate

    def insecure_certfile_path
      File.expand_path('../../insecure-test-cert.pem',
                       File.dirname(__FILE__))
    end

  end
end
