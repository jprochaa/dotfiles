# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal dotfiles for Neovim (LazyVim), tmux, bash and Alacritty, shared between macOS, Linux (Debian/Ubuntu) and Windows. Configs are **symlinked** from this repo into place, so the live config files on a machine *are* the files in this repo. `README.md` has the per-OS setup steps for a human.

## Commands

```bash
./install.sh --no-packages     # re-link configs only (safe, idempotent)
./install.sh                   # also install packages (brew / apt)
packages/update.sh             # refresh the package list for the current OS
bash -n install.sh             # syntax check; also run with /bin/bash on macOS (bash 3.2)
```

There are no tests. Verify a change by running the tool against the config:

- tmux: `tmux -L dotfiles-test -f tmux/tmux.conf new-session -d && tmux -L dotfiles-test kill-server` (isolated server, does not touch live sessions)
- nvim: `nvim --headless +qa`
- bash: `bash -lc 'echo ok'`

Use `/sync-dotfiles` after changing a config on one machine to carry the change over to the other OSes and commit it.

## Layout and where each file lands

| Repo path | macOS / Linux / WSL | Native Windows |
|---|---|---|
| `nvim/` | `~/.config/nvim` | `%LOCALAPPDATA%\nvim` |
| `tmux/tmux.conf` | `~/.config/tmux/tmux.conf` | — |
| `bash/bashrc`, `bash/bash_profile` | `~/.bashrc`, `~/.bash_profile` | — |
| `alacritty/alacritty.toml` | `~/.config/alacritty/alacritty.toml` (not linked on WSL) | imported by a generated `%APPDATA%\alacritty\alacritty.toml` |
| `alacritty/windows.toml` | — | imported after the shared file |
| `packages/Brewfile` | macOS packages | |
| `packages/apt.txt` | Linux packages (curated list that `install.sh` installs) | |
| `packages/apt-manual.txt` | Linux snapshot written by `update.sh`; reference only | |

Windows packages are the `winget` IDs listed inside `install.ps1`.

## Cross-OS rules

One file per tool is shared by every OS. Keep it that way; do not fork a config per OS.

- **bash:** anything OS-specific goes inside the `uname -s` block in `bashrc` or behind an existence check (`[ -d ... ] &&`, `command -v ... &&`). No absolute home paths; use `$HOME`. Machine-specific or secret values belong in `~/.bashrc.local`, which is outside the repo.
- **tmux:** options that only exist in newer tmux use `set -gq` so older apt versions ignore them. Plugins stay in `~/.tmux/plugins` (pinned with `TMUX_PLUGIN_MANAGER_PATH`); never commit them.
- **Alacritty:** shared settings in `alacritty.toml`; only Windows-specific overrides in `windows.toml`.
- **Windows model:** bash, tmux and the main Neovim run in WSL and are set up by `install.sh`. `install.ps1` only handles native Alacritty and Neovim.
- **Packages:** the three lists are kept equivalent by hand. A tool added to one should be added to the others under that OS's package name (for example `fd` in brew is `fd-find` in apt), or handled in `install.sh` when apt does not have a usable version (Neovim, the Nerd Font, lazygit, Alacritty).
- **Scripts:** `install.sh` must stay compatible with bash 3.2 (macOS `/bin/bash`): no associative arrays, `mapfile`, or `${var,,}`. Both installers must stay idempotent and must back files up to `~/.dotfiles-backup/<timestamp>/` rather than delete them.
- **New config:** add the file, a `link` line in `install.sh`, a `Link-Item` in `install.ps1` if it applies to Windows, and a row in the README table.

## Testing limits

Only the OS you are on can be tested. When a change affects another OS, say plainly that it is untested there. `install.ps1` and the Linux path of `install.sh` had not been run on a real machine when this file was written (2026-10-11); treat the `winget` IDs, apt package names and download URLs as unverified until they have.

## Git

Private personal repo on `main`. Never commit secrets, tokens, shell history or anything from `~/.bashrc.local`.
