#!/usr/bin/env bash

set -e

XDG_CONFIG_HOME=$(pwd)/.test-config
export XDG_CONFIG_HOME

nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"
