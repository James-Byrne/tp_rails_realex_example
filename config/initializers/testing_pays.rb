if Rails.env.development? || Rails.env.test?
  ActiveMerchant::Billing::Base.mode = :test

  module ActiveMerchant
    module Billing
      class RealexGateway
        self.test_url = "http://0.0.0.0:8000/realex/v1/auth"
        self.live_url = "http://0.0.0.0:8000/realex/v1/auth"
      end
    end
  end
end
