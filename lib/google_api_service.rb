require 'geokit'
require 'timezone'

#
# Class for working with google geocoding and timezone APIs
#
class GoogleApiService
  def initialize
    # left the key here for a quick check
    @google_api_key = ENV['GOOGLE_API_KEY']
    Geokit::Geocoders::GoogleGeocoder.api_key = @google_api_key

    Timezone::Lookup.config(:google) do |c|
      c.api_key = @google_api_key
    end
  end

  def get_tz(city)
    coords = get_city_coords("#{city} city")
    timezone = Timezone.lookup(*coords) if coords.any?

    timezone if timezone && timezone.valid?
  end

  def get_city_coords(city)
    res = Geokit::Geocoders::GoogleGeocoder.geocode city
    res.ll.split(',').map(&:to_f)
  end
end
