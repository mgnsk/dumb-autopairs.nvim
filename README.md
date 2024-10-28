# dumb-autopairs.nvim

A dumb autopairs plugin for Neovim that tries not to get in your way.

It handles inserting closing braces/quotes, `<CR>` and `<BS>`.
It does not attempt to wrap existing text.

`<CR>` works best with these settings:

```lua
vim.o.autoindent = true
vim.cmd("filetype plugin indent on")
```

## Installation

Using your favourite package manager:

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "mgnsk/dumb-autopairs.nvim",
    event = "InsertEnter",
    opts = {},
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

Note: only single-character braces/quotes are supported.
