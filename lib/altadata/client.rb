# frozen_string_literal: true

require 'faraday'
require 'json'

module Altadata
  class Client
    attr_accessor :api_key

    def initialize(api_key)
      @api_key = api_key
      @data_api_url = 'https://www.altadata.io/data/api/'
      @subscription_api_url = "https://www.altadata.io/subscription/api/subscriptions?api_key=#{@api_key}"
    end

    def list_subscription
      response = Faraday.get(@subscription_api_url)
      JSON.parse(response.body)
    end

    def check_parameter(parameter_name, parameter, data_type)
      raise "#{parameter_name} parameter must be #{data_type}" unless parameter.is_a? data_type
    end

    def get_header(product_code)
      check_parameter('product_code', product_code, String)

      request_url = "#{@data_api_url}#{product_code}/?format=json&page=1&api_key=#{@api_key}"
      response = Faraday.get(request_url)
      JSON.parse(response.body)[0].keys
    end

    def get_data(product_code, size = nil)
      check_parameter('product_code', product_code, String)

      unless size.nil?
        check_parameter('size', size, Integer)
        raise 'size parameter must be greater than 0' unless size.positive?
      end

      @size = size
      @request_url_base = "#{@data_api_url}#{product_code}/?format=json"

      self
    end

    def select(selected_column)
      check_parameter('selected_column', selected_column, Array)

      selected_column_text = selected_column.join(',')
      @request_url_base += "&columns=#{selected_column_text}"

      self
    end

    def sort(order_column, order_method = 'asc')
      check_parameter('order_column', order_column, String)
      check_parameter('order_method', order_method, String)
      order_method_array = %w[asc desc]
      raise "order_method parameter must be 'asc' or 'desc'" unless order_method_array.include? order_method

      @request_url_base += "&order_by=#{order_column}_#{order_method}"

      self
    end

    def equal(condition_column, condition_value)
      check_parameter('condition_column', condition_column, String)

      @request_url_base += "&#{condition_column}_eq=#{condition_value}"

      self
    end

    def not_equal(condition_column, condition_value)
      check_parameter('condition_column', condition_column, String)

      @request_url_base += "&#{condition_column}_neq=#{condition_value}"

      self
    end

    def greater_than(condition_column, condition_value)
      check_parameter('condition_column', condition_column, String)

      @request_url_base += "&#{condition_column}_gt=#{condition_value}"

      self
    end

    def greater_than_equal(condition_column, condition_value)
      check_parameter('condition_column', condition_column, String)

      @request_url_base += "&#{condition_column}_gte=#{condition_value}"

      self
    end

    def less_than(condition_column, condition_value)
      check_parameter('condition_column', condition_column, String)

      @request_url_base += "&#{condition_column}_lt=#{condition_value}"

      self
    end

    def less_than_equal(condition_column, condition_value)
      check_parameter('condition_column', condition_column, String)

      @request_url_base += "&#{condition_column}_lte=#{condition_value}"

      self
    end

    def condition_in(condition_column, condition_value)
      check_parameter('condition_column', condition_column, String)
      check_parameter('condition_value', condition_value, Array)

      condition_value_text = condition_value.join(',')
      @request_url_base += "&#{condition_column}_in=#{condition_value_text}"

      self
    end

    def condition_not_in(condition_column, condition_value)
      check_parameter('condition_column', condition_column, String)
      check_parameter('condition_value', condition_value, Array)

      condition_value_text = condition_value.join(',')
      @request_url_base += "&#{condition_column}_notin=#{condition_value_text}"

      self
    end

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

        unless @size.nil?
          total_size += response_json.length

          break if total_size > @size
        end

        page += 1
      end

      data = data.first(@size) unless @size.nil?

      data
    end
  end
end
