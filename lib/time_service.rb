require_relative 'format_service'
require_relative 'cache_service'
require_relative 'google_api_service'

#
# Class for getting time in different cities
# Works with google geocoder for getting TZ
#
class TimeService
  @format_service = FormatService.new

  class << self
    def get(cities = [])
      current_time = @format_service.get(Time.now.utc)
      result = ["UTC: #{current_time}"]
      result += cities.map do |city|
        city_time = get_time city
        if city_time
          formatted_time = @format_service.get city_time
          "#{city}: #{formatted_time}"
        end
      end

      result.compact
    end

    def get_time(city)
      city = city.downcase.tr(' ', '_')
      timezone = get_tz city

      timezone.time Time.now unless timezone.nil?
    end

    def get_tz(city)
      cache = CacheService.new
      google_api = GoogleApiService.new

      cached_tz = cache.get_tz(city)
      return cached_tz unless cached_tz.nil?

      google_tz = google_api.get_tz(city)
      return if google_tz.nil?

      cache.save_tz city, google_tz.name
      google_tz
    end
  end
end
