require_relative 'view'

module Simpler
  class Controller

    attr_reader :name, :request, :response, :headers

    def initialize(env, route_params)
      @name = extract_name
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
      @headers = {}
      @route_params = route_params
    end

    def make_response(action)
      @request.env['simpler.controller'] = self
      @request.env['simpler.action'] = action

      set_default_headers

      send(action)
      write_response

      set_information_headers(action)
      @headers.each { |key, value| @response[key] = value }

      @response.finish
    end

    private

    def extract_name
      self.class.name.match('(?<name>.+)Controller')[:name].downcase
    end

    def set_default_headers
      @headers['Content-Type'] = 'text/html'
    end

    def set_information_headers(action)
      @headers['X-Simpler-Controller'] = self.class.name
      @headers['X-Simpler-Action'] = action
      @headers['X-Simpler-View'] = "#{@request.env['simpler.template'] || [name, action].join('/')}.html.erb"
    end

    def write_response
      body = render_body

      @response.write(body)
    end

    def render_body
      View.new(@request.env).render(binding)
    end

    def params
      @request.params.merge(@route_params)
    end

    def render(options)
      case options
      when String
        @request.env['simpler.template'] = options
      when Hash
        if options[:plain]
          @headers['Content-Type'] = 'text/plain'
          @request.env['simpler.plain_text'] = options[:plain]
        end
      end
    end

    def status(value)
      @response.status = value
    end
  end
end
