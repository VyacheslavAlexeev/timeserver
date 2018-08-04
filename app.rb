require 'uri'
require_relative 'time_service'

# Main class of interaction of application logic and web-server
class App
  # The class contains routing logic, calling of controllers and errors handling
  def call(env)
    case env['REQUEST_PATH']
    when '/time'
      TimeController.new(env).index
    else
      HomeController.new(env).index
    end
  rescue StandardError
    ['500', { 'Content-Type' => 'text/plain' }, ['Internal server error']]
  end
end
