defmodule SimpleWeather do
  def start(cities) do
    cities
    |> Enum.map(&create_task/1)
    |> Enum.map(&Task.await/1)
  end

  defp create_task(city) do
    Task.async(fn -> Weather.temperature_of(city) end)
  end
end
