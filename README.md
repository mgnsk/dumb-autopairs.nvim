# dumb-autopairs.nvim

A dumb autopairs plugin for Neovim.

It only inserts closing braces/quotes where needed, it does not attempt to wrap existing text.

## Installation

Using your favourite package manager:

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "mgnsk/dumb-autopairs.nvim",
    event = "InsertEnter",
    config = function()
        require("dumb-autopairs").setup()
    end,
},
```

## Default config

```lua
{
    pairs = {
        {
            left = "(",
            right = ")",
        },
        {
            left = "[",
            right = "]",
        },
        {
            left = "{",
            right = "}",
        },
        {
            left = '"',
            right = '"',
        },
        {
            left = "'",
            right = "'",
        },
        {
            left = "`",
            right = "`",
        },
    },
}
```

Note: only single-character braces/quotes are currently supported.

## TODO

Handle triple backticks correctly.
