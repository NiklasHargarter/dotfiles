---
layout: default
title: Claude Code Setup
---

## Result

```
matt/course-video-manager | main | S: 0 | U: 1 | A: 0 | 17.3%
```

- **Repo path** relative to `~/`
- **Git status**: branch, staged (S), unstaged (U), added/untracked (A)
- **Context window** usage percentage — keep it under ~60% for best results

## configure npm global prefix

Avoids needing `sudo` for `npm install -g`. One-time setup:

```bash
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
```

The `~/.npm-global/bin` PATH entry is already included in the stowed `.zshrc`. Restart your shell after stowing zsh (or source it) before running the installs below.

## install Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

## install ccstatusline

```bash
npm install -g ccstatusline
```

## pre-create config directory

Required before stow so that stow links individual files instead of symlinking the entire directory into the repo.

```bash
mkdir -p ~/.claude
mkdir -p ~/.config/ccstatusline
```

## init submodules

```bash
git submodule update --init
```

## stow

```bash
stow claude
```

## configure repos directory

Repos are resolved relative to `~/`. If your repositories live in a subdirectory instead (e.g. `~/repos/`), update line 12 of `~/.claude/statusline-command.sh`:

```bash
repo_name=$(echo "$cwd" | sed "s|^$HOME/repos/||")
```

## skills

Custom skills live in `claude/.claude/skills/` and are stow-managed and git-tracked.

Skills from [mattpocock/skills](https://github.com/mattpocock/skills) are available via the vendored submodule at `vendor/mattpocock-skills/`. These are linked into `~/.claude/skills/` by a script — not copied — so they are never tracked in this repo.

To link all vendor skills (run once on setup):

```bash
bash ~/.claude/scripts/link-vendor-skills.sh
```

To update vendor skills to latest:

```bash
git submodule update --remote vendor/mattpocock-skills
```

| Skill | Description |
|---|---|
| `write-a-prd` | Create a PRD via interview, filed as a GitHub issue |
| `prd-to-plan` | Turn a PRD into a multi-phase implementation plan |
| `prd-to-issues` | Break a PRD into independently-grabbable GitHub issues |
| `grill-me` | Get relentlessly interviewed about a plan or design |
| `design-an-interface` | Generate multiple interface designs using parallel sub-agents |
| `request-refactor-plan` | Create a detailed refactor plan, filed as a GitHub issue |
| `tdd` | Red-green-refactor TDD loop, one vertical slice at a time |
| `triage-issue` | Investigate a bug, identify root cause, file a GitHub issue |
| `improve-codebase-architecture` | Find architectural improvements and testability gaps |
| `migrate-to-shoehorn` | Migrate `as` type assertions to @total-typescript/shoehorn |
| `scaffold-exercises` | Create exercise structures with problems, solutions, explainers |
| `setup-pre-commit` | Set up Husky with lint-staged, Prettier, type checking, tests |
| `git-guardrails-claude-code` | Block dangerous git commands via Claude Code hooks |
| `write-a-skill` | Create new skills with proper structure |
| `edit-article` | Edit and improve articles for clarity and structure |
| `ubiquitous-language` | Extract a DDD-style ubiquitous language glossary |
| `obsidian-vault` | Search, create, and manage Obsidian notes |

## link vendor skills

```bash
bash ~/.claude/scripts/link-vendor-skills.sh
```

## restart Claude Code

Restart Claude Code to see the status line in action.

## cleanup

```bash
# Unstow config
cd ~/dotfiles && stow -D claude

# Remove vendor skill symlinks
find ~/.claude/skills/ -type l -delete 2>/dev/null

# Uninstall global npm packages
npm uninstall -g @anthropic-ai/claude-code ccstatusline

# Remove Claude Code data and config
rm -rf ~/.claude
rm -rf ~/.config/ccstatusline

# Remove conversation history and cache
rm -rf ~/.config/claude
```

The npm global prefix (`~/.npm-global`) is shared — only remove it if no other global packages remain.
