if Rails.env.development? || Rails.env.test?
  ActiveMerchant::Billing::Base.mode = :test

  module ActiveMerchant
    module Billing
      class RealexGateway
        # Set your API Key here, and uncomment the line below, if you'd like to use the application with Testing Pays
        # self.live_url = "https://api.testingpays.com/#{ENV["REALEX_API_KEY"]}/realex/v1/auth"
      end
    end
  end
end
