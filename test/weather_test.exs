defmodule WeatherTest do
  alias Logger.Watcher
  use ExUnit.Case, async: true
  doctest Weather

  @api "http://api.openweathermap.org/data/2.5/weather?q="

  test "should return a encoded endpoint then take a location" do
    appid = Weather.get_appid()
    endpoint = Weather.get_endpoint("Rio de Janeiro")
    assert "#{@api}Rio%20de%20Janeiro&appid=#{appid}" == endpoint
  end

  test "should return celsius when take kelvin" do
    kelvin_example = 296.48
    celsius_example = 23.3

    temperature = Weather.kelvin_to_celsius(kelvin_example)

    assert temperature == celsius_example
  end

  test "should return temperature when take a valid location" do
    temperature = Weather.temperature_of("Rio de Janeiro")
    assert String.contains?(temperature, "Rio de Janeiro") == true
  end

  test "should return not found when take an invalid location" do
    result = Weather.temperature_of("000000")

    assert result == "000000 Not found"
  end
end
