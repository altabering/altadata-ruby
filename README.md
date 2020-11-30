# ALTADATA Ruby Client

[![Build Actions status](https://github.com/altabering/altadata-ruby/workflows/build/badge.svg)](https://github.com/altabering/altadata-ruby/actions)

[![Gem Version](https://badge.fury.io/rb/altadata.svg)](https://badge.fury.io/rb/altadata)

[ALTADATA](https://www.altadata.io) Ruby gem provides convenient access to the ALTADATA API from applications written in the Ruby language. With this Ruby gem, developers can build applications around the ALTADATA API without having to deal with accessing and managing requests and responses.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'altadata'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install altadata


## Quickstart

Obtain an API key in your dashboard and initialize the client:

```ruby
require 'altadata'

client = Altadata::Client.new(api_key='YOUR_API_KEY')
```

## Retrieving Data

You can get the entire data with the code below.

```ruby
data = client.get_data(product_code = PRODUCT_CODE).load
```

## Retrieving Subscription Info

You can get your subscription info with the code below.

```ruby
product_list = client.list_subscription
```

## Retrieving Data Header Info

You can get your data header with the code below.

```ruby
client.get_header(product_code = PRODUCT_CODE)
```

## Retrieving Data with Conditions

You can get data with using various conditions.

The columns you can apply these filter operations to are limited to the **filtered columns**.

> You can find the **filtered columns** in the data section of the data product page.

### equal condition

```ruby
PRODUCT_CODE = 'co_10_jhucs_03'

data =
    client.get_data(product_code = PRODUCT_CODE)
        .equal(condition_column = 'province_state', condition_value = 'Alabama')
        .load
```

### not equal condition

```ruby
PRODUCT_CODE = 'co_10_jhucs_03'

data =
    client.get_data(product_code = PRODUCT_CODE)
        .not_equal(condition_column = 'province_state', condition_value = 'Montana')
        .load
```

### in condition

```ruby
PRODUCT_CODE = 'co_10_jhucs_03'

data =
    client.get_data(product_code = PRODUCT_CODE)
        .condition_in(condition_column = 'province_state', condition_value = %w[Montana Utah])
        .load
```

> condition_value parameter of condition_in method must be Array

### not in condition

```ruby
PRODUCT_CODE = 'co_10_jhucs_03'

data =
    client.get_data(product_code = PRODUCT_CODE)
        .condition_not_in(condition_column = 'province_state', condition_value = %w[Montana Utah Alabama])
        .load
```

> condition_value parameter of condition_not_in method must be Array

### sort operation

```ruby
PRODUCT_CODE = 'co_10_jhucs_03'

data =
    client.get_data(product_code = PRODUCT_CODE)
        .sort(order_column = 'reported_date', order_method = 'desc')
        .load
```

> Default value of order_method parameter is 'asc' and order_method parameter must be 'asc' or 'desc'

### select specific columns

```ruby
PRODUCT_CODE = 'co_10_jhucs_03'

data =
    client.get_data(product_code = PRODUCT_CODE)
        .select(selected_column = %w[reported_date province_state mortality_rate])
        .load
```

> selected_column parameter of select method must be Array

### get the specified amount of data

```ruby
PRODUCT_CODE = 'co_10_jhucs_03'

data =
    client.get_data(product_code = PRODUCT_CODE, limit = 20)
        .load
```

## Retrieving Data with Multiple Conditions

You can use multiple condition at same time.

```ruby
PRODUCT_CODE = 'co_10_jhucs_03'

data =
    client.get_data(product_code = PRODUCT_CODE, limit = 100)
        .condition_in(condition_column = "province_state", condition_value = %w[Montana Utah])
        .sort(order_column = 'mortality_rate', order_method = 'desc')
        .select(selected_column = %w[reported_date province_state mortality_rate])
        .load
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## License

The gem is available as open source under the terms of the [MIT License](https://github.com/altabering/altadata-ruby/blob/master/LICENSE).