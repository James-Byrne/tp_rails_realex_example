require 'test_helper'
require 'minitest/mock'

class DonationsControllerTest < ActionController::TestCase

  # Called before every test
  setup do
    @valid_params = {
      amount: 1.10,
      first_name: "John",
      last_name: "Smith",
      number: 4111111111111111,
      cvv: 222,
      year: "2023",
      month: "12"
    }
  end

  test "should create a successful purchase" do
    @valid_params["amount"] = 1.00                  # .00 => tp_success
    post :create, params: @valid_params
    assert_response 200
    json_result = JSON.parse(response.body)
    assert_match "success", json_result["result"]
    assert_match "00", json_result["code"]
  end

  test "should return an insufficent funds message" do
    @valid_params["amount"] = 1.10                  # 10 => tp_insufficient_funds
    post :create, params: @valid_params
    assert_response 402
    json_result = JSON.parse(response.body)

    assert_match "fail", json_result["result"]
    assert_match "101", json_result["code"]
  end

  test "should return invalid card message when number is invalid" do
    @valid_params["number"] = 1234567890
    post :create, params: @valid_params
    assert_response 402
    json_result = JSON.parse(response.body)

    assert_match "credit card invalid", json_result["message"]
    assert_match "error", json_result["code"]
  end

  test "should return bank communication error" do
    @valid_params["amount"] = 1.21
    post :create, params: @valid_params
    assert_response 402
    json_result = JSON.parse(response.body)

    assert_match "We couldn't contact your bank to finailze the transaction, could you try again?", json_result["message"]
    assert_match "205", json_result["code"]
  end
end
