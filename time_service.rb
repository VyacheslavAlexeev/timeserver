require 'time'
require 'tzinfo'

class TimeService
  @time_zones = TZInfo::Timezone.all_identifiers

  def self.get cities = []
    result = [ "UTC: #{Time.now.utc}" ]
    result += cities.map do |city| 
      timezone = self.tz_offset city

      "#{city.gsub(/_/,' ')}: #{Time.now.getlocal(timezone)}" if timezone
    end

    return result.compact
  end

  def self.tz_offset city
    city = city.downcase.gsub /\s/, '_'

    tz_name = @time_zones.select { |tz| tz.downcase.match(city) }.first

    if tz_name
      TZInfo::Timezone.get(tz_name).current_period.utc_total_offset
    else
      nil
    end
  end
end
