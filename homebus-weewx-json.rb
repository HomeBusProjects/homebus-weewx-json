#!/usr/bin/env ruby

require './options'
require './app'

wj_app_options = WeeWXJSONHomebusAppOptions.new

wj = WeeWXJSONHomebusApp.new wj_app_options.options
wj.run!
