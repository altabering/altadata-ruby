# frozen_string_literal: true

require 'faraday'
require 'json'

module Altadata
  class Client
    attr_accessor :api_key

    ##
    # Sets the api key and api urls required to access the Altadata API.
    def initialize(api_key)
      @api_key = api_key
      @data_api_url = 'https://www.altadata.io/data/api/'
      @subscription_api_url = "https://www.altadata.io/subscription/api/subscriptions?api_key=#{@api_key}"
    end

    ##
    # Converts subscription api response to unnested version
    def fix_response(response_json)
      data = []

      response_json.each do |product|
        product_item = product
        product_item['createdAt'] = product_item['createdAt'].gsub('T', ' ').split('+')[0]
        product_item['validUntil'] = product_item['validUntil'].gsub('T', ' ').split('+')[0]
        product_item['title'] = product_item['offer']['title']
        product_item['code'] = product_item['offer']['code']
        product_item['price'] = product_item['plan']['price']
        product_item['plan_name'] = product_item['plan']['title']
        product_item['period'] = product_item['plan']['period']

        product_item.delete('id')
        product_item.delete('offer')
        product_item.delete('plan')

        data << product_item
      end

      data
    end

    ##
    # Retrieves customer's subscription info
    def list_subscription
      response = Faraday.get(@subscription_api_url)
      response_json = JSON.parse(response.body)
      fix_response(response_json)
    end

    ##
    # Controls types of parameters
    def check_parameter(parameter_name, parameter, data_type)
      raise "#{parameter_name} parameter must be #{data_type}" unless parameter.is_a? data_type
    end

    ##
    # Retrieves data header as an array
    def get_header(product_code)
      check_parameter('product_code', product_code, String)

      request_url = "#{@data_api_url}#{product_code}/?format=json&page=1&api_key=#{@api_key}"
      response = Faraday.get(request_url)
      JSON.parse(response.body)[0].keys
    end

    ##
    # Initializes retrieve data process
    def get_data(product_code, limit = nil)
      check_parameter('product_code', product_code, String)

      unless limit.nil?
        check_parameter('limit', limit, Integer)
        raise 'limit parameter must be greater than 0' unless limit.positive?
      end

      @limit = limit
      @request_url_base = "#{@data_api_url}#{product_code}/?format=json"

      self
    end

    ##
    # Select specific columns in the retrieve data process
    def select(selected_column)
      check_parameter('selected_column', selected_column, Array)

      selected_column_text = selected_column.join(',')
      @request_url_base += "&columns=#{selected_column_text}"

      self
    end

    ##
    # Sort data by given column and method in the retrieve data process
    def sort(order_column, order_method = 'asc')
      check_parameter('order_column', order_column, String)
      check_parameter('order_method', order_method, String)
      order_method_array = %w[asc desc]
      raise "order_method parameter must be 'asc' or 'desc'" unless order_method_array.include? order_method

      @request_url_base += "&order_by=#{order_column}_#{order_method}"

      self
    end

    ##
    # 'Equal' condition by given column and value in the retrieve data process
    def equal(condition_column, condition_value)
      check_parameter('condition_column', condition_column, String)

      @request_url_base += "&#{condition_column}_eq=#{condition_value}"

      self
    end

    ##
    # 'Not Equal' condition by given column and value in the retrieve data process
    def not_equal(condition_column, condition_value)
      check_parameter('condition_column', condition_column, String)

      @request_url_base += "&#{condition_column}_neq=#{condition_value}"

      self
    end

    ##
    # 'Greater than' condition by given column and value in the retrieve data process
    def greater_than(condition_column, condition_value)
      check_parameter('condition_column', condition_column, String)

      @request_url_base += "&#{condition_column}_gt=#{condition_value}"

      self
    end

    ##
    # 'Greater than equal' condition by given column and value in the retrieve data process
    def greater_than_equal(condition_column, condition_value)
      check_parameter('condition_column', condition_column, String)

      @request_url_base += "&#{condition_column}_gte=#{condition_value}"

      self
    end

    ##
    # 'Less than' condition by given column and value in the retrieve data process
    def less_than(condition_column, condition_value)
      check_parameter('condition_column', condition_column, String)

      @request_url_base += "&#{condition_column}_lt=#{condition_value}"

      self
    end

    ##
    # 'Less than equal' condition by given column and value in the retrieve data process
    def less_than_equal(condition_column, condition_value)
      check_parameter('condition_column', condition_column, String)

      @request_url_base += "&#{condition_column}_lte=#{condition_value}"

      self
    end

    ##
    # 'In' condition by given column and value in the retrieve data process
    def condition_in(condition_column, condition_value)
      check_parameter('condition_column', condition_column, String)
      check_parameter('condition_value', condition_value, Array)

      condition_value_text = condition_value.join(',')
      @request_url_base += "&#{condition_column}_in=#{condition_value_text}"

      self
    end

    ##
    # 'Not in' condition by given column and value in the retrieve data process
    def condition_not_in(condition_column, condition_value)
      check_parameter('condition_column', condition_column, String)
      check_parameter('condition_value', condition_value, Array)

      condition_value_text = condition_value.join(',')
      @request_url_base += "&#{condition_column}_notin=#{condition_value_text}"

      self
    end

    ##
    # Fetch data with configurations given before
    def load
      data = []
      page = 1
      total_size = 0

      loop do
        request_url = "#{@request_url_base}&page=#{page}&api_key=#{@api_key}"
        response = Faraday.get(request_url)

        response_json = JSON.parse(response.body)

        break if response_json.empty?

        response_json.each do |item|
          data << item
        end

        unless @limit.nil?
          total_size += response_json.length

          break if total_size > @limit
        end

        page += 1
      end

      data = data.first(@limit) unless @limit.nil?

      data
    end

    private :fix_response, :check_parameter
  end
end
