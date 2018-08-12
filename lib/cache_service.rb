require 'timezone'

#
# Class for working with cached timezones
#
class CacheService
  def initialize
    @cache_filename = 'cache.tmp'
  end

  def get_tz(city)
    File.open(@cache_filename, 'rb').each do |line|
      result = line.split(',')
      current_city = result[0].to_s.downcase.strip
      required_city = city.to_s.downcase.strip
      return Timezone.fetch result[1].strip if current_city.eql?(required_city)
    end

    nil
  end

  def save_tz(city, timezone)
    File.open(@cache_filename, 'ab') do |file|
      file.puts "#{city},#{timezone}"
    end
  end
end
