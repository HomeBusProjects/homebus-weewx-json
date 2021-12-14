# coding: utf-8

require 'homebus'

require 'dotenv'

require 'net/http'
require 'json'

class WeeWXJSONHomebusApp < Homebus::App
  DDC_AIR_SENSOR   = 'org.homebus.experimental.air-sensor'
  DDC_RAIN_SENSOR  = 'org.homebus.experimental.rain-sensor'
  DDC_WIND_SENSOR  = 'org.homebus.experimental.wind-sensor'
  DDC_WEATHER      = 'org.homebus.experimental.weather'
  DDC_SYSTEM       = 'org.homebus.experimental.system'
  DDC_DIAGNOSTIC   = 'org.homebus.experimental.diagnostic'
  DDC_ORIGIN       = 'org.homebus.experimental.origin'
  DDC_LICENSE      = 'org.homebus.experimental.license'

  def initialize(options)
    @options = options
    super
  end

  def update_interval
    15*60
  end

  def setup!
    Dotenv.load('.env')
    @weewx_json_url = @options[:url] || ENV['WEEWX_JSON_URL']

    @device = Homebus::Device.new name: "Weather data from #{@weewx_json_url}",
                                  manufacturer: 'Homebus',
                                  model: 'WeeWX (JSON) publisher',
                                  serial_number: @weewx_json_url

  end

  def _get_data
    begin
      uri = URI(@weewx_json_url)
      results = Net::HTTP.get(uri)

      weather = JSON.parse results, symbolize_names: true
      return weather
    rescue => error
      if @options[:verbose]
        puts "exception fetching weather URL #{uri.to_s}: #{e.message}"
      end

      return nil
    end
  end

  def F_to_C(temp)
    (temp - 32) * 5 / 9
  end

  def work!
    weather = _get_data

    if weather

      if @options[:verbose]
        puts 'WeeWX json'
        pp weather
      end

      payload = {
        temperature: ("%0.2f" % F_to_C(weather[:current][:temperature][:value])).to_f,
        humidity:  weather[:current][:humidity][:value],
        pressure: weather[:current][:barometer][:value],
        wind: weather[:current]['wind speed'.to_sym][:value],
        rain: weather[:current]['rain rate'.to_sym][:value],
        visibility: nil,
        conditions_short: nil,
        conditions_long: nil
      }

      payload[:conditions_short] = _conditions_short(payload)
      payload[:conditions_long] = _conditions_long(payload)

      if @options[:verbose]
        puts 'Homebus payload'
        pp payload
      end

      @device.publish! DDC_WEATHER, payload
    else
      puts 'failed to get weather'
    end

    sleep update_interval
  end

  def _conditions_temperature(temperature)
    case temperature
    when ..0
      'freezing'
    when 0..13
      'cold'
    when 13..21
      'cool'
    when  21..27
      'normal'
    when 27..33
      'warm'
    else
      'hot'
    end
  end

  def _conditions_humidity(humidity)
    case humidity
    when 0..20
      'parched'
    when  20..40
      'dry'
    when 40..75
      'normal'
    when 75..90
      'moist'
    else
      'damp'
    end
  end

  # from https://www.weather.gov/pqr/wind
  def _conditions_wind(wind)
    case wind
    when 0
      'calm'
    when 0..3
      'light'
    when 3..7
      'light breeze'
    when 7..12
      'gentle breeze'
    when 12..18
      'moderate breeze'
    when 18..24
      'fresh breeze'
    when 24..31
      'strong breeze'
    when 31..38
      'near gale'
    when 38..46
      'gale'
    when 46..54
      'strong gale'
    when 54..63
      'whole gale'
    when 63..75
      'storm force'
    else
      'hurricane force'
    end
  end

  def _conditions_short(payload)
    "#{_conditions_temperature(payload[:temperature]).capitalize}, #{_conditions_humidity(payload[:humidity])}, #{_conditions_wind(payload[:wind])}"
  end

  def _conditions_long(payload)
    "Temperature is #{_conditions_temperature(payload[:temperature])}, air feels #{_conditions_humidity(payload[:humidity])}. Wind is #{_conditions_wind(payload[:wind])}"
  end

  def name
    'Homebus WeeWX Weather (JSON) publisher'
  end

  def publishes
    [ DDC_WEATHER, DDC_AIR_SENSOR, DDC_RAIN_SENSOR, DDC_WIND_SENSOR, DDC_SYSTEM, DDC_DIAGNOSTIC, DDC_ORIGIN, DDC_LICENSE ]
  end

  def devices
    [ @device ]
  end
end
