# frozen_string_literal: true

require_relative '../lib/altadata'

API_KEY = ENV['TEST_API_KEY']
PRODUCT_CODE = 'co_10_jhucs_03'

RSpec.describe Altadata do
  client = Altadata::Client.new(api_key = API_KEY)

  it 'has a version number' do
    expect(Altadata::VERSION).not_to be nil
  end

  it 'has a valid return at list_subscription method ' do
    subscription_info = client.list_subscription
    product_code_arr = []

    subscription_info.each do |info|
      product_code_arr << info['offer']['code']
    end

    product_code_list = %w[CO_10_JHUCS_04 CO_08_UNXXX_04
                           CO_10_JHUCS_03 CO_07_IDEAX_02]

    expect(product_code_arr).to eq(product_code_list)
  end

  it 'has a valid return at get_header method ' do
    header = %w[reported_date province_state population lat
                lng confirmed prev_confirmed_1d new_confirmed
                peak_confirmed_1d_flag active deaths prev_deaths_1d
                new_deaths most_deaths_1d_flag recovered
                hospitalization_rate incidence_rate mortality_rate
                people_hospitalized people_tested testing_rate]

    expect(client.get_header(product_code = PRODUCT_CODE)).to eq(header)
  end

  it 'has a valid return at get_data method with sort' do
    data =
      client.get_data(product_code = PRODUCT_CODE, size = 10)
            .equal(condition_column = 'province_state', condition_value = 'Alabama')
            .sort(order_column = 'reported_date', order_method = 'asc')
            .load

    expect(data[0]['reported_date']).to eq('2020-04-12')
  end

  it 'has a valid return at get_data method with select' do
    selected_columns = %w[reported_date province_state mortality_rate]
    data =
      client.get_data(product_code = PRODUCT_CODE, size = 10)
            .select(selected_column = selected_columns)
            .load

    expect(data[0].keys).to eq(selected_columns)
  end

  it 'has a valid return at get_data method with in' do
    data =
      client.get_data(product_code = PRODUCT_CODE, size = 250)
            .condition_in(condition_column = 'province_state', condition_value = %w[Montana Utah])
            .load

    province_state_arr = []

    data.each do |item|
      province_state_arr << item['province_state']
    end

    province_state_arr.uniq!

    expect(province_state_arr).to eq(%w[Montana Utah])
  end

  it 'has a valid return at get_data method with not in' do
    check_list = %w[Montana Utah Alabama]

    data =
      client.get_data(product_code = PRODUCT_CODE, size = 250)
            .condition_not_in(condition_column = 'province_state', condition_value = check_list)
            .load

    province_state_arr = []

    data.each do |item|
      province_state_arr << item['province_state']
    end

    province_state_arr.uniq!

    check_list.each do |item|
      expect(province_state_arr).not_to include(item)
    end
  end
end
