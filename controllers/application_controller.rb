#
# Base class for all controllers
#
class ApplicationController
  def initialize(env)
    @env = env
  end
end
