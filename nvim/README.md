# nvim

A small, hand-written Neovim config. No framework, no hidden magic — every
plugin is one file in `lua/plugins/` with a comment saying what it does. Read
the whole thing in ten minutes and you know your editor.

Leader key is **space**. Forgot a binding? Press `<space>` and wait — **which-key**
lists everything.

## Layout

```
init.lua                entry point (loads the three below)
lua/config/options.lua  editor settings (numbers, indent, clipboard…)
lua/config/keymaps.lua  global keymaps not owned by a plugin
lua/config/lazy.lua     bootstraps lazy.nvim, loads lua/plugins/
lua/plugins/*.lua       one plugin per file
lazy-lock.json          exact plugin versions (COMMIT THIS)
```

## Plugins

| File | Plugin | Does |
|---|---|---|
| colorscheme | tokyonight | theme |
| treesitter | nvim-treesitter | syntax-tree highlighting + indent |
| telescope | telescope + fzf-native | fuzzy find files / grep / buffers |
| oil | oil.nvim | file manager as an editable buffer |
| which-key | which-key.nvim | popup listing keybindings |
| completion | blink.cmp | autocomplete popup (LSP/buffer/path/snippets) |
| lsp | lspconfig + mason | language servers: defs, hover, rename, diagnostics |
| formatting | conform.nvim | format on save |
| gitsigns | gitsigns.nvim | git hunks in the gutter + stage/reset |
| lualine | lualine.nvim | statusline |

## Keymaps

**Windows / motion**
| Key | Action |
|---|---|
| `<C-h/j/k/l>` | move between splits |
| `<C-d>` / `<C-u>` | half-page down/up (centred) |
| `n` / `N` | next/prev search (centred) |
| `J` / `K` (visual) | move selected lines down/up |
| `<Esc>` | clear search highlight |

**Files & search** (`<leader>f` = find)
| Key | Action |
|---|---|
| `-` | open current directory in oil |
| `<leader>ff` | find files |
| `<leader>fg` | live grep across project |
| `<leader>fb` | open buffers |
| `<leader>fw` | grep word under cursor |
| `<leader>fh` | help tags |
| `<leader>fd` | project diagnostics |
| `<leader>fr` | resume last search |

**Code / LSP** (active when a language server is attached)
| Key | Action |
|---|---|
| `grd` | go to definition |
| `grr` | references |
| `gri` | implementation |
| `K` | hover docs |
| `<leader>cr` | rename symbol |
| `<leader>ca` | code action |
| `<leader>cd` | line diagnostics |
| `[d` / `]d` | prev/next diagnostic |

**Git** (`<leader>g`)
| Key | Action |
|---|---|
| `]c` / `[c` | next/prev hunk |
| `<leader>gp` | preview hunk |
| `<leader>gs` | stage hunk |
| `<leader>gr` | reset hunk |
| `<leader>gb` | blame line |
| `<leader>gd` | diff file |

**Misc**
| Key | Action |
|---|---|
| `<leader>w` / `<leader>q` | write / quit |
| `<leader>a` | ask Claude in a side pane (no inline autocomplete) |

## Languages

LSP + formatting configured for: Lua, Python, C/C++, Rust, Bash, YAML, JSON,
TOML, Dockerfile, Markdown. Servers install automatically via **mason** on first
launch — check status with `:Mason`.

- **Rust formatting** uses `rustfmt`, which comes with the `rustup` toolchain
  that `setup.sh` installs (not mason). `zsh/rust.zsh` puts `~/.cargo/bin` on PATH.
- Add a language: put its server name in the `servers` table in
  `lua/plugins/lsp.lua` and its treesitter parser in `lua/plugins/treesitter.lua`,
  then restart.

## AI, deliberately kept out of the buffer

There is no inline AI autocomplete — that's the point of this config. When you
want to ask something, `<leader>a` opens Claude Code in a Zellij floating pane
next to the editor. You ask, you read, nothing edits your file. To add true
in-editor chat later, install `olimorris/codecompanion.nvim` as a new file in
`lua/plugins/`.

## Prerequisites

- **Neovim ≥ 0.11** (uses the native `vim.lsp.config` API). `setup.sh` installs a
  current build on both macOS (brew) and Linux (official tarball).
- **A C compiler + make** — treesitter and telescope-fzf-native compile on
  install. macOS: Xcode Command Line Tools (`xcode-select --install`). Linux:
  `build-essential` (installed by `setup.sh`).
- **ripgrep** for `live_grep`, **fd** for fast file finding — both already in the
  dotfiles package list.

## Maintaining it

- `:Lazy` — plugin manager UI. `:Lazy update` bumps versions → **commit the
  changed `lazy-lock.json`** so every machine matches.
- `:checkhealth` — diagnoses missing dependencies.
- A fresh machine reproduces your exact setup from `lazy-lock.json`. That
  lockfile is the cure for version drift — keep it committed.
