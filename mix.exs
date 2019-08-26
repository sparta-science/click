defmodule Click.MixProject do
  use Mix.Project

  def project do
    [
      app: :click,
      deps: deps(),
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      version: "0.1.6"
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Click, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:chrome_remote_interface, "~> 0.3"},
      {:chroxy, "~> 0.6"},

      # Dev-only
      {:ex_doc, "~> 0.20.2", only: :dev},

      # Test-only
      {:floki, "~> 0.21", only: :test}
    ]
  end
end
