defmodule Click.TestSupport.Html do
  def normalize(html) when is_list(html),
    do: html |> Enum.map(&normalize/1)

  def normalize(html) when is_binary(html),
    do: html |> as_string() |> Floki.parse() |> Floki.raw_html()

  def normalize(not_html),
    do: not_html

  def as_string({:safe, iodata}),
    do: IO.iodata_to_binary(iodata)

  def as_string(string),
    do: string
end
