require 'homebus/options'

class WeeWXJSONHomebusAppOptions < Homebus::Options
  def app_options(op)
    url_help = 'the URL of the weather station\'s JSON report'

    op.separator 'WeeWXJSON options:'
    op.on('-l', '--url weewx_json_url', url_help) { |value| options[:url] = value }
  end

  def banner
    'HomeBus WeeWX JSON report publisher'
  end

  def version
    '0.0.1'
  end

  def name
    'homebus-weewx-json'
  end
end
