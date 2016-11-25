require 'securerandom'
require 'active_merchant'

module RealexHandlerModule
  extend ActiveSupport::Concern

  # Set the realex gateway
  @@gateway = ActiveMerchant::Billing::RealexGateway.new(
    login: "YOUR-API-KEY-HERE", #tp api key
    password: "secret"
  )

  # Method for creating a purchase request with Realex
  # The body of this method will be submitted into the realex_handler method
  # which is in charge of returning the relevant response to the calling
  # controller
  # NOTE : Realex deals with amount as cent values, so 20.00 becomes 2000.
  def create_purchase(amount, credit_card, options = {order_id: SecureRandom.random_number(40)})
    realex_handler do
      @@gateway.purchase((amount.to_f * 100).to_i, credit_card, options)
    end
  end

  # A helper function that allows us to create cards from controllers using
  # ActiveMerchants credit card class
  def create_card(card)
    ActiveMerchant::Billing::CreditCard.new(
      :number     => card[:number],
      :month      => card[:month],
      :year       => card[:year],
      :first_name => card[:first_name],
      :last_name  => card[:last_name],
      :verification_value  => card[:verification_value]
    )
  end

  # The realex handler method takes the response from a realex operation such as
  # purchase, capture, authorize. It then sorts the responses and determines the
  # correct message to return to the client.
  #
  # NOTE : This is not an exhaustive list of errors, more errors and how to deal
  # with them can be found here : TODO : Add link to testing pays site here

  # NOTE : For the sake of simplicity the error codes and their responses are
  # sorted here. In a real situation it would be worth creating another module or
  # a yml file to contain them
  def realex_handler
    # Get the result of the realex operation
    result = yield

    # Create a response based off the result code returned from the operation
    case result.params["result"]
    when "00"
      return {
        message: "Purchase was succesful.",
        http_code: 200,
        result: "success",
        code: "00"
      }
    when "101"
      return {
        message: "Sorry the transaction was declined by the Bank. This is generally caused by insufficient funds",
        http_code: 402,
        result: "fail",
        code: "101"}
    when "102"
      return {
        message: "Transaction Declined Pending Offline Authorisation.",
        http_code: 402,
        result: "fail",
        code: "102"
      }
    when "205"
      return {
        message: "We couldn't contact your bank to finailze the transaction, could you try again?",
        http_code: 402,
        result: "fail",
        code: "205"
      }
    else
      return {
        message: "An issue has arisen please contact us at support@example.com",
        http_code: 422,
        result: "fail",
        code: ""
      }
    end
  end
end
