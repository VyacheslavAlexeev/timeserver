require 'cgi'
require_relative 'time_service'

class App
  def call(env)
    case env['REQUEST_PATH']
    when '/time'
      cities = self.prepare_cities env['QUERY_STRING']
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

  def prepare_cities query
    parsed_query = CGI.parse(query)
    key = parsed_query.keys.first

    raw_cities = 
      if key == 'cities'
        parsed_query[key].first
      else
        key
      end

    raw_cities.to_s.split(',').map { |city| city }
  end
end
