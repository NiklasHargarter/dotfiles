# Zsh + Oh My Zsh Quick Guide

This guide explains the most important features in your current shell setup.

Your active config is in:
- `.zshrc` (plugins, theme, behavior)
- Oh My Zsh framework under `ohmyzsh/`

---

## 1) Most important Zsh features

### Smart completion
- Press `Tab` to complete commands, files, options, branches, etc.
- With your `HYPHEN_INSENSITIVE="true"`, `-` and `_` can be treated similarly in completion.

### Strong history
- You can search old commands quickly (`Ctrl + R`).
- Reuse/modify previous commands instead of retyping.

### Powerful line editor (ZLE)
- Built-in command-line editing (move cursor, cut/yank words, clear screen, etc.)
- Works similarly to Emacs-style shell editing by default.

### Globbing and expansion
- Better wildcard matching than basic shell setups.
- Easier file selection with patterns.

---

## 2) Most important Oh My Zsh features

### Plugin system
- Load features by listing plugin names in `plugins=(...)`.
- You currently use:
  - `git`
  - `fzf`
  - `eza`
  - `zsh-autosuggestions`
  - `zsh-completions`
  - `fzf-tab`
  - `zsh-syntax-highlighting`

### Theme system
- You use `powerlevel10k/powerlevel10k`.
- Prompt can show git status, exit code, duration, time, etc.

### Update management
- You set update reminders every 14 days.

---

## 3) Plugin features (what each gives you)

## `git`
- Huge alias set for daily Git work.
- Examples:
  - `gst` → `git status`
  - `gco` → `git checkout`
  - `gcmsg "msg"` → commit with message
  - `gl` / `gp` → pull / push

## `fzf`
- Fuzzy finder integration (search/select interactively).
- Adds common fuzzy widgets and keybindings (see keys below).

## `eza`
- Replaces/augments `ls` workflows with nicer output.
- Useful aliases like `ls`, `ll`, `la`, `lD` via the plugin.

## `zsh-autosuggestions`
- Shows grey inline suggestions from history while typing.
- Accept suggestion with right-arrow or end-of-line key.

## `zsh-completions`
- Adds extra completion definitions for many commands.
- Improves command/flag/subcommand completion coverage.

## `fzf-tab`
- Uses fzf UI for `Tab` completion menus.
- Faster filtering when there are many completion results.

## `zsh-syntax-highlighting`
- Colors commands as you type.
- Helps spot typos before pressing Enter.

---

## 4) Important keys and what they do

## Core Zsh keys (line editing)
- `Ctrl + A` → move cursor to start of line
- `Ctrl + E` → move cursor to end of line
- `Ctrl + B` / `Ctrl + F` → move left/right by one char
- `Alt + B` / `Alt + F` → move left/right by one word
- `Ctrl + W` → delete previous word
- `Ctrl + U` → delete from cursor to line start
- `Ctrl + K` → delete from cursor to line end
- `Ctrl + Y` → paste last killed text
- `Ctrl + L` → clear screen
- `Ctrl + C` → cancel current command
- `Ctrl + D` → EOF / exit shell (if line is empty)
- `Ctrl + Z` → suspend foreground process

## ZLE cut/copy/select (very useful)

### Cut a full line
- `Ctrl + A`, then `Ctrl + K` → cut whole line (start → end)
- If cursor is at end: `Ctrl + U` → cut whole line (start ← cursor)

### Copy a full line (without deleting)
- `Ctrl + A` to go to start
- `Ctrl + Space` (or `Ctrl + @`) to set mark
- `Ctrl + E` to go to end
- `Esc`, then `W` (Meta+W / `copy-region-as-kill`) to copy region

### Select and cut/copy part of a line (Emacs keymap)
- `Ctrl + Space` (or `Ctrl + @`) → start selection (set mark)
- Move cursor with arrows / `Alt + B` / `Alt + F`
- `Ctrl + W` → cut selected region
- `Esc`, then `W` → copy selected region
- `Ctrl + Y` → paste (yank)
- `Alt + Y` → cycle older killed/copied entries after a yank

### Handy word operations
- `Alt + D` → cut word forward
- `Ctrl + W` → cut word backward
- `Alt + Backspace` → cut word backward (in many terminals)

## History/search keys
- `Up` / `Down` → previous/next command history
- `Ctrl + R` → interactive reverse history search

## Completion keys
- `Tab` → trigger completion
- `Tab` (again) → cycle/list alternatives (depends on context)

## fzf keys (from fzf integration)
- `Ctrl + R` → fuzzy search command history
- `Ctrl + T` → fuzzy insert file/path
- `Alt + C` → fuzzy jump to directory

## autosuggestion keys
- `Right Arrow` (or end-of-line key) → accept suggestion

## fzf-tab UI keys (inside completion popup)
- `Tab` / arrows → move selection (depends on terminal config)
- `Enter` → accept selected completion
- `Esc` / `Ctrl + C` → cancel selection

> Note: exact key behavior can vary by terminal and local keymap.

---

## 5) Practical everyday workflow

1. Start typing command.
2. Use autosuggestion (right arrow) if suggestion is correct.
3. Use `Tab` (`fzf-tab`) to pick files/options quickly.
4. Use `Ctrl + R` when you remember part of an old command.
5. Use short Git aliases (`gst`, `gco`, `gcmsg`, `gl`, `gp`).

