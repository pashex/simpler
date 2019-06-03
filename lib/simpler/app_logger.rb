require 'logger'

module Simpler
  class AppLogger

    def initialize(app, **options)
      @logger = Logger.new(options[:logdev] || STDOUT)
      @app = app
    end

    def call(env)
      @status, @header, @body = @app.call(env)
      request = Rack::Request.new(env)
      response = Rack::Response.new(@body, @status, @header)
      @logger.info("Request: #{request.request_method} #{request.fullpath}")
      @logger.info("Handler: #{controller}##{action}")
      @logger.info("Parameters: #{request.params}")
      @logger.info("Response: #{status_string} [#{content_type}] #{view}")
      response.finish
    end

    private

    def status_string
      Rack::Utils::HTTP_STATUS_CODES[@status]
    end

    def content_type
      @header['Content-Type']
    end

    def controller
      @header['X-Simpler-Controller']
    end

    def action
      @header['X-Simpler-Action']
    end

    def view
      @header['X-Simpler-View']
    end
  end
end
