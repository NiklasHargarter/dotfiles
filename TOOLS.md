# Tools

`tools` to read this. What each one is *for*, not what it replaces. The base tools
(`find`, `grep`) are here too, because knowing the replacement is useless if the
original never made sense.

---

## eza — list files

`ls` shows names. `eza` shows names, sizes, dates, permissions and git state in one
readable table. Aliased to `ls`, `ll`, `tree`.

```
ll                      long, all, human sizes, git status column   (your alias)
tree                    recursive tree                              (your alias)
eza -T -L 2             tree, only 2 levels deep — the useful one
eza --git-ignore        hide what git ignores, so no node_modules/__pycache__
eza -l -s modified      sort by mtime — what did I touch last?
eza -l -s size -r       biggest first
eza -l --total-size     real recursive dir sizes, not the 4096 stub
```

The git column in `ll`: `N` new, `M` modified, `-` untracked-ignored. Faster than
`git status` for "what's dirty in this folder".

---

## find and fd — locate files by name/attribute

**`find` is the original.** Its syntax is a filter chain, and once you see the shape
it stops being scary:

```
find <where> <tests> <action>

find . -name "*.py"                 name matches glob (quote it!)
find . -type f                      files only        (-type d = dirs)
find . -type f -name "*.log" -delete
find . -mtime -7                    modified in last 7 days
find . -size +100M                  bigger than 100 MB
find . -maxdepth 2 -name "*.md"     don't descend forever
find . -name "*.pyc" -exec rm {} +  run a command on each hit
```

The gotchas that make people give up: the glob **must be quoted** or the shell eats
it, `-name` is exact-match-with-globs (not substring), and tests come *before* the
action.

**`fd` is the same job with sane defaults.** Substring match, regex, skips
`.gitignore`d files and hidden files automatically, parallel.

```
fd nvim                 anything with "nvim" in the name, anywhere below
fd -e py                by extension
fd -t f / -t d          files only / dirs only
fd -H                   include hidden (it skips them by default)
fd -I                   include gitignored files
fd nvim -x wc -l        run a command per result
fd -e py -X rg TODO     ONE command with all results appended
```

`-x` runs once per file, `-X` runs once with everything. That distinction is the
whole reason `fd` beats `find -exec` for speed.

---

## grep and rg — search inside files

**`grep` is the original.** Searches file *contents* for a pattern.

```
grep -r "pattern" .        recursive — the flag people forget
grep -n                    show line numbers
grep -i                    case insensitive
grep -w                    whole word — not "cat" inside "concatenate"
grep -v                    invert: lines that DON'T match
grep -l                    just list filenames
grep -c                    count matches
grep -E "a|b"              extended regex (alternation, +, ?)
```

**`rg` is grep that already knows it's in a repo.** Recursive by default, honours
`.gitignore`, skips binaries, ~10× faster, colourised with line numbers on.

```
rg pattern                 that's it — recursive, ignores .git and gitignored files
rg -i / -w                 same meanings as grep
rg -t py pattern           only Python files   (-t md, -t yaml, -t rust…)
rg -T test pattern         EXCLUDE a type
rg -l pattern              filenames only
rg -C 3 pattern            3 lines of context either side (-A after, -B before)
rg --hidden --no-ignore    search everything, gitignore be damned
rg -g '!*.lock' pattern    glob filter
rg -F 'literal$string'     no regex, treat as literal
rg 'old' -r 'new'          preview a replacement (prints, does not write)
```

`rg --files | rg foo` is the fast "find by name" if you'd rather not learn `fd`.

---

## bat — read files

`cat` dumps bytes. `bat` adds syntax highlighting, line numbers, git modification
marks, and paging when the file is long.

```
bat file.py             highlighted, numbered, paged
bat -p file.py          plain — no numbers/borders, so you can still copy-paste
bat -r 40:60 file.py    just lines 40-60
bat -A file             show tabs/newlines — for "why won't this parse"
bat -l yaml < input     force a language when reading a pipe
```

Pipe it into things: `rg -l TODO | xargs bat`. When output goes to a pipe rather
than a terminal it degrades to plain `cat`, so it's safe in scripts.

---

## jq — query JSON

For `docker inspect`, API responses, any `*.json`. Filters are a path language.

```
jq . file.json                    pretty-print + colour  (the 90% use)
jq -r .name                       raw output, no quotes — for shell vars
jq .items[]                       iterate an array
jq '.[] | .name'                  field from each element
jq '.[] | select(.state=="running")'
jq '{name, id}'                   pick a subset into a new object
jq -c .                           compact, one line per record
jq 'length'                       how many
```

Your case: `docker inspect <c> | jq -r '.[0].NetworkSettings.IPAddress'`.

Pair with `-r` whenever the result goes into a variable, or you get quotes in it.

---

## zoxide — jump to directories

Already installed as your `cd` (`bash/bashrc`). It remembers every directory you
visit and ranks by *frecency* — frequency plus recency.

```
cd dotfiles          jump from anywhere, no path needed
cd nv cfg            match by multiple fragments
cd ~/some/real/path  still a normal cd — falls through when the path exists
cdi                  fzf picker over your ranked dirs
cd -                 previous dir (plain bash, still works)
zoxide query -ls     see the ranking it has built for you
```

The database needs a few days of use before it feels magic. It's been building
since you installed it.

---

## fzf — fuzzy-pick anything

A filter that turns any list into an interactive picker. Two ways to use it.

**As keybindings** (already wired in `bash/bashrc`):

```
Ctrl+r      search shell history       ← replaces ↑↑↑
Alt+c       fuzzy-cd into a subdir
Ctrl+t      insert a file path         ← zellij's tab mode eats this one
**<Tab>     fuzzy-complete after any command:  cd **<Tab>,  git checkout **<Tab>
```

**As a pipe**, which is where it gets good:

```
git branch | fzf                              pick a branch
docker ps --format '{{.Names}}' | fzf         pick a container
fd -e py | fzf --preview 'bat --color=always {}'    pick with a live preview
git checkout $(git branch | fzf)              use the pick inline
```

Inside fzf: type to filter, `Ctrl+j/k` to move, `Enter` to pick, `Esc` to bail.

---

## btop — what's using this machine

Full-screen system monitor: CPU per core, memory, network, disk, process tree.
Strictly more than `htop`.

```
btop
```

Inside: `1` toggles per-core, `f` filter processes, `t` tree view, `+`/`-` expand,
`k` kill, `Esc` menu, `q` quit. Mouse works.

---

## ncdu — what's using this disk

Scans a tree, sorts by size, lets you walk in and delete. The answer to "the disk is
full and I don't know why".

```
ncdu /            whole system (skips other filesystems)
ncdu ~            just home
```

Inside: arrows to walk, `d` delete, `n`/`s` sort by name/size, `q` quit.

---

## gh — GitHub from the terminal

```
gh pr create --fill        PR from current branch, title/body from commits
gh pr list / gh pr view    with --web to open in a browser
gh pr checkout 42          check out someone's PR locally
gh repo clone owner/name
gh run list / gh run watch CI status without leaving the terminal
gh api /user               raw API, pipes into jq
```

---

## How they compose

The point isn't any one tool, it's that they pipe:

```
fd -e py | fzf --preview 'bat --color=always {}'     pick a file, see it first
rg -l TODO | xargs bat                                read every file with a TODO
docker ps -q | xargs docker inspect | jq -r '.[].Name'
rg --files | rg test | xargs eza -l -s modified       test files by recency
```
