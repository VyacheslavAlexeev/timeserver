require 'time'
require 'tzinfo'
require 'geokit'
require 'timezone'

class TimeService
  # оставил ключ здесь намеренно, можно убрать в ENV, но лишние заморочки при проверке
  @google_api_key = '***REMOVED***'

  Geokit::Geocoders::GoogleGeocoder.api_key = @google_api_key
  Timezone::Lookup.config(:google) do |c|
   c.api_key = @google_api_key
  end

  @time_zones = TZInfo::Timezone.all_identifiers
  @format = '%Y-%m-%d %H:%M:%S'
  @cache_filename = 'cache.tmp'

  def self.get cities = []
    result = [ "UTC: #{Time.now.utc.strftime(@format)}" ]
    result += cities.map do |city| 
      time_string = self.get_time(city).strftime(@format)

      "#{city.gsub(/_/,' ')}: #{time_string}" if time_string
    end

    return result.compact
  end

  def self.get_time city
    # имею опыт в собирании базы стран-штатов-городов с координатами. Тут просто не стал усложнять
    # а проблему задержки при поиске часового пояса решил кэширорванием
    city = city.downcase.gsub /\s/, '_'
    cached_tz = find_tz_in_cache(city)

    if cached_tz.nil?
      res = Geokit::Geocoders::GoogleGeocoder.geocode city
      coords = res.ll.split(',').map { |c| c.to_f }
    
      if coords.any?
        timezone = Timezone.lookup(*coords)
        write_tz_to_cache city, timezone.name if timezone.valid?
      end
    else
      timezone = Timezone.fetch(cached_tz.delete "\n")
    end

    timezone.time Time.now if timezone.valid?
  end

  # кэширование организовал на файле, для избежания зависимостей от внешних сервисов
  def self.find_tz_in_cache city
    if File.exist? @cache_filename
      File.open(@cache_filename, 'rb').each do |line|
        result = line.split(',')
        if result[0].to_s.downcase == city.to_s.downcase
          return result[1]
        end
      end

      return nil
    end
  end

  def self.write_tz_to_cache city, timezone
    File.open(@cache_filename, 'ab') do |file|
      file.puts "#{city},#{timezone}"
    end
  end
end
