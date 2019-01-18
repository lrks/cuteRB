require "cuterb/version"

module CuteRB
  class Error < StandardError; end

  class CLI
    def initialize(text, image, output)
      @text = text
      @image = image
      @output = output
    end

    def run()
      p @text
      p @image
      p @output
      return 0
    end
  end
end
