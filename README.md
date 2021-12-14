# homebus-weewx-json

This is a simple HomeBus data source which publishes weather
conditions provided by a [WeeWX server](http://weewx.com).

## Usage

On its first run, `homebus-aqi` needs to know how to find the HomeBus provisioning server.

```
bundle exec homebus-weewx-json
```

## WeeWX JSON

The WeeWX server must have the
[JSON extension installed](https://github.com/teeks99/weewx-json) and
enabled. This extension adds a new report type which generates a
`.json` file that this publisher uses to retrieve weather conditions.

## Configuration

The `.env` file must contain the URL for the WeeWX server.

```
WEEWX_JSON_URL=http://octopi.local:8001/weewx.json
```
