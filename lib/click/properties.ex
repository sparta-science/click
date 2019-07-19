defmodule Click.Properties do
  def get(properties, property_name) when is_binary(property_name),
    do: properties |> Enum.find(&(&1["name"] == property_name)) |> value()

  def get(properties, property_names) when is_list(property_names),
    do: property_names |> Enum.map(&get(properties, &1))

  def get_all(properties),
    do: properties |> Enum.map(&{&1["name"], value(&1)}) |> Map.new()

  defp value(property),
    do: property |> Map.get("value") |> type_specific_value()

  defp type_specific_value(%{"type" => type} = value) when type in ["object", "symbol", "function"],
    do: value["description"]

  defp type_specific_value(value),
    do: value["value"]
end
