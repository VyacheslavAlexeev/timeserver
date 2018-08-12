require 'time'

#
# Class for formating of time
#
class FormatService
  def initialize
    @format = '%Y-%m-%d %H:%M:%S'
  end

  def get(time)
    time.strftime(@format)
  end
end
