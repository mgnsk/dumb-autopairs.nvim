#!/usr/bin/env bash

set -e

PACK_DIR=./.test-config/nvim/pack/tests/start

mkdir -p "$PACK_DIR"
git clone https://github.com/nvim-lua/plenary.nvim.git "$PACK_DIR/plenary.nvim"
