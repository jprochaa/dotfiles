# dotfiles

My Neovim, tmux, bash and Alacritty configuration, shared between macOS, Linux and Windows.

Configs are **symlinked** from this repo into place, so editing a config edits the repo. To sync a change: commit, push, and `git pull` on the other machines.

## What is in here

| Folder | Linked to (macOS / Linux / WSL) | On native Windows |
|---|---|---|
| `nvim/` | `~/.config/nvim` | `%LOCALAPPDATA%\nvim` |
| `tmux/tmux.conf` | `~/.config/tmux/tmux.conf` | not used (tmux runs in WSL) |
| `bash/bashrc` | `~/.bashrc` | not used (bash runs in WSL) |
| `bash/bash_profile` | `~/.bash_profile` | not used |
| `alacritty/alacritty.toml` | `~/.config/alacritty/alacritty.toml` | imported by `%APPDATA%\alacritty\alacritty.toml` |
| `alacritty/windows.toml` | not used | imported after the shared file (opens WSL) |
| `packages/Brewfile` | Homebrew packages (macOS) | |
| `packages/apt.txt` | apt packages (Debian / Ubuntu) | |

## Set up a new machine

### macOS

1. Install [Homebrew](https://brew.sh).
2. Clone and run:

   ```bash
   git clone git@github.com:<your-user>/dotfiles.git ~/dotfiles
   ~/dotfiles/install.sh
   ```

This installs everything in `packages/Brewfile` (including the JetBrainsMono Nerd Font that the Alacritty config uses), links the configs and installs the tmux plugins.

### Linux (Debian / Ubuntu)

```bash
sudo apt update && sudo apt install -y git
git clone git@github.com:<your-user>/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

Besides the packages in `packages/apt.txt`, the script installs:

- **Neovim** from the official release into `~/.local/opt` (apt's version is too old for LazyVim).
- **JetBrainsMono Nerd Font** into `~/.local/share/fonts`.
- **Alacritty** and **lazygit** from apt when the release has them; otherwise it prints a warning and you install them by hand.

### Windows

bash, tmux and Neovim run inside **WSL**; Alacritty runs on Windows and opens WSL.

1. Install WSL (`wsl --install`), open it, and follow the **Linux** steps above inside it.
2. On the Windows side, turn on Developer Mode (Settings > System > For developers) so symlinks can be created, then in PowerShell:

   ```powershell
   git clone git@github.com:<your-user>/dotfiles.git $HOME\dotfiles
   cd $HOME\dotfiles
   powershell -ExecutionPolicy Bypass -File .\install.ps1
   ```

This installs Alacritty, Neovim, Git and the Nerd Font with `winget`, links the Neovim config, and writes an Alacritty config that imports the files from this repo.

### Options

- `./install.sh --no-packages` / `.\install.ps1 -NoPackages` — only link the configs.
- The scripts are safe to re-run. A file that is already in the way is moved to `~/.dotfiles-backup/<timestamp>/`, never deleted.

## Keeping machines in sync

After changing a config or installing a package on any machine, open [Claude Code](https://claude.com/claude-code) in this folder and run:

```
/sync-dotfiles
```

It works out what changed on this machine, makes the matching change for the other OSes (package lists, OS guards, install scripts, this README), checks it, then commits and pushes. On the other machines run `git pull`, and re-run the install script if packages or links changed.

Without Claude Code the manual version is: `packages/update.sh`, edit the other OS's package list to match, commit and push.

## Machine-specific settings

Anything that should not be shared (work paths, tokens, one-off aliases) goes in `~/.bashrc.local`. It is sourced at the end of `bashrc` and is not part of this repo.

## Package lists

- **macOS:** `packages/update.sh` rewrites `Brewfile` from what is installed now.
- **Linux:** `packages/update.sh` writes everything you installed by hand to `packages/apt-manual.txt`. Copy the ones you want on every machine into `packages/apt.txt`, which is the list `install.sh` installs.

`apt.txt` was written by hand as an equivalent of the Brewfile, so adjust it after the first run on a real Linux machine.

## Adding another config

1. Move the file or folder into this repo (for example `git/gitconfig`).
2. Add a `link` line for it in `install.sh` (and `Link-Item` in `install.ps1` if it applies to Windows).
3. Run `./install.sh --no-packages`, then commit.

## First upload to GitHub

```bash
cd ~/dotfiles
gh auth login
gh repo create dotfiles --private --source . --push
```

Or create an empty private repo on github.com and:

```bash
git remote add origin git@github.com:<your-user>/dotfiles.git
git push -u origin main
```

## Notes

- tmux plugins are managed by [TPM](https://github.com/tmux-plugins/tpm) and live in `~/.tmux/plugins`, outside this repo. `prefix + I` installs new ones.
- The tmux prefix is `Ctrl+Space`; `prefix + q` reloads the config.
- `nvim/lazy-lock.json` is committed so every machine gets the same plugin versions. After `:Lazy update`, commit the changed lock file.
