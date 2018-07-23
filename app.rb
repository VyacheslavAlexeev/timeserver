require 'uri'
require_relative 'time_service'

class App
  def call(env)
    case env['REQUEST_PATH']
    when '/time'
      cities = self.prepare_cities env['REQUEST_URI']
      result = TimeService.get(cities)

      if result
        ['200', {'Content-Type' => 'text/plain'}, [result.join("\n")]]
      else
        ['400', {'Content-Type' => 'text/plain'}, ['Bad request']]
      end
    else
      ['200', {'Content-Type' => 'text/plain'}, ['OK']]
    end
  end

  def prepare_cities uri
    parsed_query = URI.parse(uri).query
    URI.decode(parsed_query.to_s).to_s.split(',').map { |city| city }
  end
end
