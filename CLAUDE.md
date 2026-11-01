# Dotfiles

Agent-operated. The user should only be involved for what needs them personally.

## Set up this machine

`scripts/bootstrap.sh` lands here with a prompt, or the user asks directly.

1. Run `./scripts/setup.sh`. It is idempotent. If it failed, fix the cause and
   re-run; fix the repo too if the cause isn't specific to this machine.
2. Verify, and fix what fails:
   - `zsh -ic 'echo ok'` prints no errors
   - `ls -l ~/.zshrc ~/.zshenv ~/.gitconfig ~/.claude/settings.json ~/.config/nvim` all point into the repo
   - every tool in the `brew install` / `apt-get install` lines of `setup.sh` runs
3. Walk the human steps below, skipping any already done. One at a time.
4. Finish with what's done and what's left. On macOS, a missing Ghostty is the
   user's to install; it isn't in `setup.sh`.

### Human steps

Your shell has no TTY, so these can't run from your Bash tool. Give the exact
command for the user to run in a second terminal, wait, then verify.

| Step | Skip if | User runs | Verify |
|---|---|---|---|
| Sudo or login shell, if `setup.sh` reported needing them | `$SHELL` is `/bin/zsh` | `chsh -s /bin/zsh`, or `./scripts/setup.sh` for a sudo failure | `dscl . -read ~ UserShell` or `getent passwd $USER` |
| GitHub SSH key | `ssh -T git@github.com` greets them | `./scripts/setup-ssh-keys.sh github.com`, paste at github.com/settings/ssh/new | `ssh -T git@github.com` |
| `gh` login | `gh auth status` passes | `gh auth login` | `gh auth status` |
| Other SSH hosts | key exists at the host's `IdentityFile` | `./scripts/setup-ssh-keys.sh <host>`. Ask which of `ssh/config`'s hosts this machine needs; some need the VPN | `ssh -o BatchMode=yes <host> true` |
| VPN, if this machine needs it | `~/.vpn-creds` exists | `cp vpn/creds.template ~/.vpn-creds && chmod 600 ~/.vpn-creds`, then edit it | file exists, mode 600; don't read it |

Secrets never enter this conversation: don't ask for them, and don't read
`~/.vpn-creds`, `~/.vpn-cert.pem` or private keys.

## Update this machine

`git pull`, then `./scripts/setup.sh`, then step 2 above. Changes to already
linked files are live after the pull. If local edits block the pull, compare
with upstream: drop what's already there, lift anything new into the repo. Report
the rest; don't discard it.

## Changing this repo

- New app config: add a `link` line to `setup.sh`.
- New human step: add it to the table above.
- Keep `setup.sh` idempotent and able to run without a TTY once a machine is set
  up: sudo and `chsh` only when something is actually missing.
- `README.md` describes the daily-use surface; keep it in step.
