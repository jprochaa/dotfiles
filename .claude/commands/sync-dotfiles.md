---
description: Carry config changes made on this machine over to the other OSes, then commit and push
argument-hint: "[optional note about what changed]"
---

I changed one or more configs on this machine. Make the equivalent change for the other operating systems this repo supports, then commit and push. Follow the cross-OS rules in `CLAUDE.md`.

Extra context from me (may be empty): $ARGUMENTS

## 1. Find out what changed

- Detect the current OS (`uname -s`; on Linux check `/proc/version` for WSL).
- `git pull --rebase --autostash` if a remote is configured, so the work starts from the latest version. If it conflicts, stop and show me.
- `git status` and `git diff` to see the config edits.
- Run `packages/update.sh` and diff the result to see packages installed or removed on this machine. On Linux this writes `packages/apt-manual.txt`; compare it with `packages/apt.txt` and only consider packages I plausibly installed on purpose, not the distro's base set.

If nothing changed, say so and stop.

## 2. Carry each change across

For every change, decide which of these it is and act:

- **Works everywhere as written** (most nvim, tmux and Alacritty settings): nothing more to do.
- **Not portable as written** (absolute home path, Homebrew path, a command that only exists on one OS, a tmux option newer than apt's tmux): rewrite it using the guards described in `CLAUDE.md` so the same file still works on all three.
- **Windows-only or needs a Windows variant** (shell, paths): put the override in `alacritty/windows.toml` or `install.ps1`.
- **New package:** add the equivalent to the other lists — `packages/Brewfile`, `packages/apt.txt`, and the `winget` list in `install.ps1` when it is useful on native Windows. Use the right name per package manager. If apt has no usable version, add an install step to `install.sh` next to the existing Neovim one, or note it in the README as a manual step.
- **Removed package:** remove it from the other lists too, but ask me first if it is unclear whether I still want it elsewhere.
- **New config file or folder:** add the `link` line in `install.sh`, a `Link-Item` in `install.ps1` if it applies to Windows, and a row in the tables in `README.md` and `CLAUDE.md`.
- **Machine-specific or secret:** do not commit it. Move it to `~/.bashrc.local` and tell me.

Update `README.md` when setup steps or the file table change.

## 3. Check

- `bash -n install.sh packages/update.sh` (on macOS also with `/bin/bash`).
- Run `./install.sh --no-packages` and confirm every line says `ok` or `linked`.
- Load whichever config changed: tmux on an isolated server (`tmux -L dotfiles-test -f tmux/tmux.conf new-session -d`, then `kill-server`), `nvim --headless +qa`, `bash -lc true`.
- Scan the diff for tokens, passwords or keys before committing.

## 4. Commit and push

- Show me a short summary of the diff, then commit with a message that says what changed.
- Push if a remote exists. If there is none, tell me and point at the "First upload" section of the README.

## 5. Report

Tell me, briefly:

- what changed on this OS and what you changed for the others;
- what you could **not** test because it belongs to another OS;
- what I need to do on the other machines: normally `git pull`, plus `./install.sh` (or `.\install.ps1`) if packages or links changed.
