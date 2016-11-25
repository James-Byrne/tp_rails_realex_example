if Rails.env.development? || Rails.env.test?
  ActiveMerchant::Billing::Base.mode = :test

  module ActiveMerchant
    module Billing
      class RealexGateway
        self.live_url = "https://api.testingpays.com/realex/v1/auth"
      end
    end
  end
end
