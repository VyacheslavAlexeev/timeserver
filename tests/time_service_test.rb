require_relative '../app'
require 'minitest/autorun'

describe TimeService do
  before do
    @time_service = TimeService
  end

  describe 'when asked Moscow' do
    it 'must respond moscow tz' do
      @time_service.get_tz('Moscow').name.must_equal 'Europe/Moscow'
    end
  end

  describe 'when asked not existing city' do
    it 'must respond nil' do
      @time_service.get_tz('Notexist').must_be_nil
    end
  end
end
