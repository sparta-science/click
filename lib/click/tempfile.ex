defmodule Click.Tempfile do
  def write(data, extension) when is_binary(data) do
    path = Briefly.create!(extname: extension)
    File.write!(path, data)
    path
  end
end
