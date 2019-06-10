#!/usr/bin/env bash

port=${1:-9222}

/Applications/Chromium.app/Contents/MacOS/Chromium --headless --remote-debugging-port=${port}