defmodule Weather do
  @moduledoc """
  Documentation for `Weather`.
  """

  def start(cities) do
    # Cria um processo da função manager inicializando com
    # uma lista vazia e o total de cidades.

    # O manager fica "segurando" o estado da lista vazia e do total de cidades.

    # __MODULE__ se refere ao próprio módulo em que estamos no momento.
    manager_pid = spawn(__MODULE__, :manager, [[], Enum.count(cities)])

    # Percorre a lista de cidades e cria um processo para cada uma com a função get_temperature().

    # Envia uma mensagem para este processo passando a cidade e o PID do manager.
    cities
    |> Enum.map(fn city ->
      pid = spawn(__MODULE__, :get_temperature, [])
      send(pid, {manager_pid, city})
    end)
  end

  def get_temperature() do
    # Recebe o PID do manager e a cidade.

    # Envia uma mensagem de volta ao manager com a temperatura da cidade.

    # O coringa entende qualquer outra coisa como um erro.

    # Chama get_temperature() no final para o processo continuar vivo e esperando por mensagens.
    receive do
      {manager_pid, location} ->
        send(manager_pid, {:ok, temperature_of(location)})

      _ ->
        IO.puts("Error")
    end

    get_temperature()
  end

  def manager(cities \\ [], total) do
    # Se o manager receber a temperatura e :ok a mantém em uma lista (que foi inicializada como vazia no início).

    # Se o total da lista for igual ao total de cidades avisa a si mesmo para parar o processo com :exit.
    # Se receber :exit ele executa a si mesmo uma última vez para processar o resultado.
    # Ao receber o atom :exit para o processo, ordena o resultado e o mostra na tela.

    # Caso não receba :exit executa a si mesmo de maneira recursiva passando a nova lista e o total.
    # O coringa no final executa a si mesmo com os mesmos argumentos em caso de erro.

    receive do
      {:ok, temp} ->
        results = [temp | cities]

        if Enum.count(results) == total do
          send(self(), :exit)
        end

        manager(results, total)

      :exit ->
        IO.puts(cities |> Enum.sort() |> Enum.join())

      _ ->
        manager(cities, total)
    end
  end

  def get_appid() do
    System.get_env("WEATHER_KEY")
    |> IO.inspect(label: "lib/weather.ex:8")
  end

  def get_endpoint(location) do
    location = URI.encode(location)

    "http://api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{get_appid()}"
    |> IO.inspect(label: "lib/weather.ex:13")
  end

  def kelvin_to_celsius(kelvin) do
    (kelvin - 273.15) |> Float.round(1)
  end

  def temperature_of(location) do
    result = get_endpoint(location) |> HTTPoison.get() |> parser_response

    case result do
      {:ok, temp} ->
        "#{location}: #{temp}°C"

      :error ->
        "#{location} Not found"
    end
  end

  defp parser_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body |> JSON.decode!() |> compute_temperature
  end

  defp parser_response(_), do: :error

  defp compute_temperature(json) do
    try do
      temp = json["main"]["temp"] |> kelvin_to_celsius
      {:ok, temp}
    rescue
      _ -> :error
    end
  end
end
