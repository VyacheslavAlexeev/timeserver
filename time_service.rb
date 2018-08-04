require 'time'
require 'tzinfo'
require 'geokit'
require 'timezone'

#
# Class for getting time in different cities
# Works with google geocoder for getting TZ
#
class TimeService
  # left the key here for a quick check
  @google_api_key = '***REMOVED***'

  Geokit::Geocoders::GoogleGeocoder.api_key = @google_api_key
  Timezone::Lookup.config(:google) do |c|
    c.api_key = @google_api_key
  end

  @time_zones = TZInfo::Timezone.all_identifiers
  @format = '%Y-%m-%d %H:%M:%S'
  @cache_filename = 'cache.tmp'

  def self.get(cities = [])
    result = ["UTC: #{Time.now.utc.strftime(@format)}"]
    result += cities.map do |city|
      time_string = get_time(city).strftime(@format)

      "#{city.tr('_', ' ')}: #{time_string}" if time_string
    end

    result.compact
  end

  def self.get_time(city)
    city = city.downcase.tr(' ', '_')
    timezone = get_city_tz city

    timezone.time Time.now if timezone.present?
  end

  def self.get_city_tz(city)
    cached_tz = find_tz_in_cache(city)

    timezone =
      if cached_tz.present?
        Timezone.fetch cached_tz.delete("\n")
      else
        get_tz_by_coords(city)
      end

    timezone if timezone.valid?
  end

  def self.get_tz_by_coords(city)
    coords = get_city_coords(city)
    if coords.present?
      timezone = Timezone.lookup(*coords)
      write_tz_to_cache city, timezone.name if timezone.valid?
    end

    timezone if timezone.valid?
  end

  def self.get_city_coords(city)
    res = Geokit::Geocoders::GoogleGeocoder.geocode city
    res.ll.split(',').map(&:to_f)
  end

  def self.find_tz_in_cache(city)
    nil unless File.exist? @cache_filename

    File.open(@cache_filename, 'rb').each do |line|
      result = line.split(',')
      result[1] unless result[0].to_s.casecmp city.to_s.downcase
    end
  end

  def self.write_tz_to_cache(city, timezone)
    File.open(@cache_filename, 'ab') do |file|
      file.puts "#{city},#{timezone}"
    end
  end
end
