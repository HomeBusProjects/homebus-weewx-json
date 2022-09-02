require 'homebus/options'

require 'homebus-weewx-json/version'

class HomebusWeewxJson::Options < Homebus::Options
  def app_options(op)
    url_help = 'the URL of the weather station\'s JSON report'

    op.separator 'WeeWXJSON options:'
    op.on('-l', '--url weewx_json_url', url_help) { |value| options[:url] = value }
  end

  def banner
    'HomeBus WeeWX JSON report publisher'
  end

  def version
    HomebusWeewxJson::VERSION
  end

  def name
    'homebus-weewx-json'
  end
end
