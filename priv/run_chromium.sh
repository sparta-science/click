#!/usr/bin/env bash

port=${1:-9222}

# Window size is set to 10,000px high so that all elements are visible and therefore clickable.
# In the future, we should scroll to the element we want to click on before clicking on it.
/Applications/Chromium.app/Contents/MacOS/Chromium --headless --remote-debugging-port=${port} --window-size="1024x10000"