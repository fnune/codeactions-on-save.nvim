# codeactions-on-save.nvim

A Neovim plugin to register specific code actions to be run automatically on
file save, based on file patterns.

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "fnune/codeactions-on-save.nvim",
  config = function()
    local cos = require("codeactions-on-save.nvim")
    cos.register({ "*.py" }, { "source.organizeImports" })
    cos.register({ "*.ts", "*.tsx" }, { "source.organizeImports.biome", "source.fixAll" })
  end
}
```

The default timeout for code actions is 100ms. You can pass anything else if necessary, in `ms`:

```lua
cos.register({ "*.ts" }, { "source.organizeImports" }, 3000)
```

## Inspecting code actions

To find out the action kind of the action you want to run, use this while
inside a buffer with an LSP client attached:

```
:lua require("codeactions-on-save").inspect()
```
