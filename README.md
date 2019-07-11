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

If there were docs, they'd be at [https://hexdocs.pm/click](https://hexdocs.pm/click). 

## Required environment variables

### `CLICK_BROWSER_PATH`
Click uses the `CLICK_BROWSER_PATH` environment variable to find a suitable chrome/chromium.

On Linux, you might find the chrome executable at `/opt/google/chrome/google-chrome`

On MacOS, you might find the chromium executable at `/Applications/Chromium.app/Contents/MacOS/Chromium`

### `SHELL`
[erlexec](https://github.com/saleyn/erlexec/blob/11a168d2c1eef7b7882a06d52b0c0c4aa63fb05b/c_src/exec.cpp#L501) might blow up with `SHELL environment variable not set!`; try setting `SHELL` to `/bin/bash` or something.

## Developing

### Resources

* [recipes](https://github.com/cyrus-and/chrome-remote-interface/wiki)
