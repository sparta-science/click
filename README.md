# Click

Acceptance testing tool that uses Chrome DevTools Protocol (CDP) to interact with Chrome.

## Development

Currently, to run the Click test suite, you need to run Chromium manually.  

1. Install: `brew bundle`
2. Run: `priv/run_chromium.sh`
3. Test: `mix test`


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `click` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:click, "~> 0.1.0"}
  ]
end
```

For application testing, Click can be started in AcceptanceCase. Take a look at Glacier Point.

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/click](https://hexdocs.pm/click).

