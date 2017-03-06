# Realex Rails Example Application

Integrated example application using [Realex's Auth API](https://developer.realexpayments.com/#!/api/process-payment/authorisation).

## Requirements

In order to run this application you will need the following:
- [ruby](https://www.ruby-lang.org/en/) (version 2.2+)
  - We recommend you use a ruby version manager, such as [rvm](https://rvm.io/)
  - If you are using windows you can find a ruby installer [here](http://rubyinstaller.org/downloads/)

## setup

firstly pull down the repo.

``` bash
$ git clone https://github.com/testingpays/realex_rails_example_app.git
```

next enter the directory and install the applications dependencies using bundler

``` bash
$ gem install bundler
$ bundle install
```

## running the application

now that we have the application installed and our api keys setup we can start using the application. firstly lets run the tests to make everything is in order.

```bash
$ rails test
```

your tests should have ran successfully. now to run the application use the following command.

```bash
$ rails server
```

your application should now be running [locally](http://localhost:3000/charges).

### API Keys

Insert your Realex test keys to start with

```ruby
# Set the realex gateway
@@gateway = ActiveMerchant::Billing::RealexGateway.new(
  login: "YOUR-API-KEY-HERE",
  password: "SECRET"
)
```

### Developing with Testing Pays

In order to work with [Testing Pays](http://www.testingpays.com) you need to provide your API Key. When working with Realex we replace our login and password fields with your Testing Pays API key. This is done in the [realex_handler_module](app/controllers/concerns/realex_handler_module.rb).

> Note that we ignore the password field and ___do not___ require your actual Realex password.

This application points to the Testing Pays Realex auth API when running in both development and testing modes. This is set in the [testing_pays initializer](config/initializers/testing_pays.rb).

```ruby
# config/initializers/testing_pays.rb
if Rails.env.development? || Rails.env.test?
  ActiveMerchant::Billing::Base.mode = :test

  module ActiveMerchant
    module Billing
      class RealexGateway
        self.live_url = "https://api.testingpays.com/#{ENV["TESTING_PAYS_KEY"]}/realex/v1/auth"
      end
    end
  end
end
```

### Unit Testing with Testing Pays

Testing Pays makes testing many types of responses easy. In order to get a particular response simply pass in the associated response mapping, which is based on the cent part of the amount field:

```ruby
amount: X.10  # => insufficient funds
amount: X.21  # => bank communications error
amount: X.00   # => success
```

For a full list of response mappings see the [response mappings table](https://admin.testingpays.com/) under your account.

```ruby
# test/controllers/charges_controller_test.rb

require 'test_helper'
require 'minitest/mock'

class ChargesControllerTest < ActionController::TestCase

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
```
