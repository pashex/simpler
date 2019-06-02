module Simpler
  class Router
    class Route

      attr_reader :controller, :action

      def initialize(method, path, controller, action)
        @method = method
        @path = convert_path_to_regex(path)
        @controller = controller
        @action = action
      end

      def match?(method, path)
        @method == method && @path.match?(path)
      end

      def params(path)
        match_data = @path.match(path)
        match_data && Hash[match_data.names.map(&:to_sym).zip(match_data.captures)]
      end

      private

      def convert_path_to_regex(path)
        Regexp.new("#{path.gsub(/:(?<param>\w+)/, '(?<\k<param>>\w+)')}\\Z")
      end
    end
  end
end
