module Tunnel
  class Request
    def initialize(env)
      @env          = env
      @rack_request = Rack::Request.new(@env)
    end

    def method
      rack_request.env.fetch('REQUEST_METHOD')
    end

    def path
      rack_request.env.fetch('REQUEST_PATH')
    end

    def ip
      rack_request.env.fetch('REMOTE_ADDR')
    end

    def headers
      rack_request.env.each_with_object({}) do |(key, value), hash|
        if key.start_with?('HTTP_')
          hash[key.gsub('HTTP_', '')] = value
        end
      end
    end

    def parsed_body
      JSON.parse(body)
    end

    def body
      @body ||= rack_request.body.read
    end

    private

    attr_reader :rack_request
  end
end
