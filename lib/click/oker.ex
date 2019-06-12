defmodule Click.Oker do
  def normalize({:ok, value}), do: {:ok, value}
  def normalize({:error, value}), do: {:error, value}

  def normalize(list) when is_list(list) do
    for {status, value} <- Enum.reverse(list), reduce: {:ok, []} do
      {:ok, list} ->
        if status == :ok,
          do: {:ok, [value | list]},
          else: {:error, [value | list]}

      {:error, list} ->
        {:error, [value | list]}
    end
  end
end
