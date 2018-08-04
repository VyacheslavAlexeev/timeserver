#
# Home controller
# Triggered on /
#
class HomeController < ApplicationController
  def index
    ['200', { 'Content-Type' => 'text/plain' }, ['OK']]
  end
end
