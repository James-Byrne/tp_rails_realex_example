class ChargesController < ApplicationController
  include RealexHandlerModule
  before_action :get_card, only: [:create]

  def index
  end

  def create
    amount = params[:amount]

    # Validating the card automatically detects the card type
    if @card.validate.empty?
      result = create_purchase(amount, @card)

      render(json: result, status: result[:http_code]) && return
    end
    render(json: {message: "credit card invalid", code: "error"}, status: 402)
  end

private
  def get_card
    @card = create_card({
      first_name: params[:first_name],
      last_name: params[:last_name],
      number: params[:number],
      month: params[:month],
      year: params[:year],
      verification_value: params[:cvv]
    })
  end
end
