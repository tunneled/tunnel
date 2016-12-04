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
        if key.start_with?('HTTP_') && key != 'HTTP_VERSION'
          name = humanize(key.gsub('HTTP_', ''))
          hash[name] = value
        end
      end
    end

    def formatted_body
      return unless parsed_body
      JSON.pretty_generate(parsed_body)
    end

    def parsed_body
      return if body.empty?
      JSON.parse(body)
    end

    def body
      @body ||= rack_request.body.read
    end

    private

    attr_reader :rack_request

    def humanize(string)
      pieces = string.split(/_|-/)
      pieces.map { |piece| piece.capitalize }.join('-')
    end
  end
end
