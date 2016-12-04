require_relative 'terminal_support'
require_relative 'request'

module Tunneled
  class Server
    include TerminalSupport

    def initialize(port:)
      @port   = port || 9292
      @tunnel = Process.spawn(ssh_command)
    end

    def start
      Rack::Server.start(app: self)
    end

    def call(env)
      @request  = Request.new(env)
      @response = Rack::Response.new

      print_delimiter
      print_request_info
      print_newline
      print_headers
      print_newline
      print_request_body
      yank_request_body_to_clipboard

      #TODO: Forward request to http://localhost:#{port}

      response.status = 200
      response['Content-Type'] = 'text/html'
      response.write(default_html)

      print_delimiter
      puts "\n\n"

      response.finish
    rescue => exception
      puts red(exception.to_s)
      puts red(exception.backtrace.join("\n"))
      binding.pry
    end

    private

    attr_reader :port, :request, :response

    def print_delimiter
      puts grey('*' * TERMINAL_SIZE)
    end

    def print_newline
      puts
    end

    def print_request_info
      info            = "#{request.ip} - #{request.method} #{request.path}"
      time_of_request = Time.now.to_s

      spaces = ' ' * (TERMINAL_SIZE - (info.size + time_of_request.size))

      puts yellow("#{info}#{spaces}#{time_of_request}")
    end

    def print_headers
      request.headers.each do |key, value|
        puts purple("#{key}: #{value}").strip
      end
    end

    def print_request_body
      puts cyan(request.formatted_body)
    end

    def yank_request_body_to_clipboard
      system("echo '#{request.formatted_body}' | pbcopy")
    end

    def default_html
      <<-HTML
      <html>
      <div style="text-align:center;margin-top:100px;">
        <p style="font-size:50px;">👋</p>
        <a style="font-size:12px;" href="https://git.io/v1lip">[source]</a>
        </div>
      </html>
      HTML
    end

    def ssh_command
      "ssh -nNT -R 80:localhost:#{port} root@tunneled.computer"
    end
  end
end
