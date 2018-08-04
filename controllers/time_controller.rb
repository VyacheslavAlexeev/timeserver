require 'CGI'

#
# Time controller.
# Triggered on /time
#
class TimeController < ApplicationController
  def index
    cities = prepare_cities @env['REQUEST_URI']
    result = TimeService.get(cities)

    if result
      ['200', { 'Content-Type' => 'text/plain' }, [result.join("\n")]]
    else
      ['400', { 'Content-Type' => 'text/plain' }, ['Bad request']]
    end
  end

  def prepare_cities(uri)
    parsed_query = URI.parse(uri).query
    CGI.unescape(parsed_query.to_s).to_s.split(',').map { |city| city }
  end
end
