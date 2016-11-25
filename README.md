# Testing Pays
<img src="TestingPaysLogo.png" width="250" height="200" align="right">
> Demonstrating how Testing Pays API can be used to test Realex's payment processor.

### Existing Projects
To integrate an existing project with TestingPays we recommend you follow the short guide on your [instructions page](https://admin.testingpays.com/teams_apis/realex-v1-auth).

### Requirements
In order to run this application you will need the following:
- [ruby](https://www.ruby-lang.org/en/) (version 2.2+)
  - We recommend you use [rvm](https://rvm.io/) to manage your ruby versions
  - If you are using windows you can find a ruby installer [here](http://rubyinstaller.org/downloads/)


- [node.js](https://nodejs.org/en/) (latest LTS)


##### Accounts
You will also require an account with [TestingPays](http://www.testingpays.com/).

### Setup
Firstly pull down the repo.
``` bash
$ git clone https://github.com/ThePaymentWorks/tp_rails_realex_example.git
```

Next enter the directory and install the applications dependencies.

``` bash
$ cd tp_rails_realex_example/
$ bundle install
```

##### API Keys
In order to work with TestingPays we need to provide our TestingPays api key. When working with Realex we replace our login and password fields with our TestingPays API key. This is done in the [realex_handler_module](app/controllers/concerns/realex_handler_module.rb).

```ruby
# Set the realex gateway
@@gateway = ActiveMerchant::Billing::RealexGateway.new(
  login: "YOUR-API-KEY-HERE", #tp api key
  password: "secret"
)
```
> Note that we ignore the password field and ___do not___ require your actual Realex password.


### Running the application
Now that we have the application installed and our api keys setup we can start using the application. Firstly lets run the tests to make everything is in order.

```bash
$ rails t
```

Your tests should have ran successfully. Now to run the application use the following command.

```bash
$ rails s
```

Your application should now be running [locally](http://localhost:3000/donations).


### Integrating with TestingPays
We do not recommend you use this application in production. It is just for example purposes.

This application points to the TestingPays Realex auth api when running in both development and testing modes. This is set in the [testing_pays initializer](config/initializers/testing_pays.rb).

```ruby
# config/initializers/testing_pays.rb
if Rails.env.development? || Rails.env.test?
  module RealexGateway
    @api_base = "https://api.testingpays.com/realex/v1/auth"
  end
end
```


### Testing with TestingPays
TestingPays makes testing many types of responses easy. In order to get a particular response simply pass in the associated response mapping. E.g.

```ruby
amount: 91  # => rate_limit_error
amount: 80  # => card_expired
amount: 0   # => success
```

For a full list of response mappings see the [response mappings table](https://admin.testingpays.com/teams_apis/realex-v1-auth).

```ruby
# test/controllers/donations_controller_test.rb

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
```
