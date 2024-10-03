# Syntax Highlighted Cursor

Use your synatx highlighting color for the neovim cursor.

![Screenshot](screenshot.gif)


## Inspirations

- [st - simple terminal](https://st.suckless.org/patches/dynamic-cursor-color/)
- [kovidgoyal/kitty](https://github.com/kovidgoyal/kitty/issues/126)
- [asottile/babi]()


## Installation

If you use [lazy.nvim](https://github.com/folke/lazy.nvim), add:

```lua
{
    "ukyouz/syntax-highlighted-cursor.nvim",
    config = function()
        require("syntax-highlighted-cursor").setup({
            -- Options
        })
    end,
},
```

## Options


```lua
{
    -- If you feel updating cursor color is too often for you, try make debounce_ms bigger.
    debounce_ms = 50,
}
```

Note that the last update delay is determined by `updatetime` option which triggers the `CursorHold` autocmd event.

## Limitations

- Required Lua, so only work in Neovim
- Required `guicursor` support
