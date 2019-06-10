defmodule Click.Chrome do
  def result({:ok, %{"result" => result}} = _response),
    do: {:ok, result}

  def result({:ok, %{"result" => result}}, key),
    do: {:ok, Map.get(result, key)}
end
