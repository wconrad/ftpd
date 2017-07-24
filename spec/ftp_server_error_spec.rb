# frozen_string_literal: true

module Ftpd
  describe FtpServerError do

    it "won't instantiate with an invalid error code" do
      expect { described_class.new("Nooooooooo", 665) }.to(
        raise_error(ArgumentError, "Invalid response code")
      )
    end

  end
end
