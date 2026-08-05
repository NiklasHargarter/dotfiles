# Focus

Run `focus` to read this. Edit the **This week** block on Monday, move the old one
to Done, and pick the next rotation item. That is the whole system.

Rule: six things per week, not sixty. A binding is learned when you stop reaching
for the fallback, not when you can recite it.

---

## This week

Zellij movement — the split you already make every day.

```
Alt+←  Alt+→       focus pane
Alt+n              new pane
Ctrl+p r / d       split right / down
Ctrl+p x           close pane
Alt+b / Ctrl+→     word jump in the shell
Alt+.              last arg of the previous command
```

Rules to enforce, not memorise:

- No mouse for pane focus.
- Never hold an arrow key along a line.
- Never `↑↑↑` through history — `Ctrl+r`.

---

## Rotation

**Tabs** — `Ctrl+t n` new, `Ctrl+t r` name it, `Ctrl+t 1-9` jump, `Ctrl+t Tab` last.
Shell: `Ctrl+w`, `Alt+d`. Goal: stop splitting panes for things that aren't
side-by-side.

**Scroll and kill-ring** — `Ctrl+s` then `u`/`d` half page, `e` dumps the scrollback
into nvim. Shell: `Ctrl+u`, `Ctrl+k`, `Ctrl+y`. Goal: stop scrolling with the mouse
to read a test failure.

**nvim motion** — set `hardtime` `max_count` to 2 in
`nvim/lua/plugins/hardtime.lua`, then live with it. `f`/`t`, `}`/`{`, `ciw`, `%`.
Goal: stop repeating `hjkl`.

**nvim navigation** — `<space>f` telescope, `-` oil, flash `s`. Goal: stop leaving
nvim to find a file.

---

## Which layer does which job

The most common mistake is doing a job at the wrong layer.

| Job | Layer | Not |
|---|---|---|
| Open another **file** | nvim — `<space>f`, `-`, `:vsplit` | a new zellij pane |
| Run another **process** | zellij pane or tab | a backgrounded job |
| Different **project** | zellij session — `Alt+1/2/3` | a new Ghostty window |
| Watch two things at once | zellij pane split | flipping tabs |
| A separate task, same project | zellij tab | another pane |
| Throwaway one-off command | floating pane — `Alt+f` | disturbing the layout |

Session = context. Tab = task. Pane = two things at once.

---

## Look it up

- **zsh** — `keys`
- **zellij** — `Ctrl+o` then `c`
- **nvim** — press `<space>` and wait (which-key)

These read the live config, so they are never stale. Do not write a cheat sheet.

---

## Done

_(move finished weeks here, newest first)_
