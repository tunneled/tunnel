module Tunnel
  module TerminalSupport
    TERMINAL_SIZE = 80

    def purple(text)
      colorize(text, 35)
    end

    def cyan(text)
      colorize(text, 36)
    end

    def grey(text)
      colorize(text, 90)
    end

    def yellow(text)
      colorize(text, 33)
    end

    def red(text)
      colorize(text, 31)
    end

    def colorize(text, color)
      "\e[#{color}m#{text}\e[0m"
    end
  end
end
