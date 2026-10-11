#!/usr/bin/env bash
# Set up a macOS, Linux or WSL machine from this repo.
# Safe to re-run: existing files are moved to ~/.dotfiles-backup, never deleted.
#
#   ./install.sh                 install packages, then link configs
#   ./install.sh --no-packages   only link configs
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
PACKAGES=1

for arg in "$@"; do
    case "$arg" in
        --no-packages) PACKAGES=0 ;;
        -h|--help) sed -n '2,6p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "Unknown option: $arg" >&2; exit 1 ;;
    esac
done

info() { printf '\033[34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[33mwarning:\033[0m %s\n' "$*" >&2; }

# --- OS detection -----------------------------------------------------------
case "$(uname -s)" in
    Darwin) OS=macos ;;
    Linux)
        if grep -qi microsoft /proc/version 2>/dev/null; then OS=wsl; else OS=linux; fi
        ;;
    *) echo "Unsupported OS: $(uname -s). On Windows use install.ps1." >&2; exit 1 ;;
esac
info "Detected: $OS"

# --- Packages ---------------------------------------------------------------
install_macos_packages() {
    if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew is not installed. Install it from https://brew.sh and re-run." >&2
        exit 1
    fi
    info "Installing Homebrew packages from packages/Brewfile"
    brew bundle --file "$DOTFILES/packages/Brewfile" || warn "some Brewfile entries failed; see output above"
}

# apt's Neovim is too old for LazyVim, so use the official release build.
install_linux_neovim() {
    local have
    have="$(nvim --version 2>/dev/null | sed -n '1s/^NVIM v//p' || true)"
    case "$have" in
        0.1[1-9]*|0.[2-9][0-9]*|[1-9]*) info "Neovim $have already installed"; return ;;
    esac
    local arch
    case "$(uname -m)" in
        x86_64) arch=x86_64 ;;
        aarch64|arm64) arch=arm64 ;;
        *) warn "no Neovim release build for $(uname -m); install it manually"; return ;;
    esac
    info "Installing Neovim (latest release) into ~/.local/opt"
    mkdir -p "$HOME/.local/opt" "$HOME/.local/bin"
    curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-$arch.tar.gz" \
        | tar -xz -C "$HOME/.local/opt"
    ln -sfn "$HOME/.local/opt/nvim-linux-$arch/bin/nvim" "$HOME/.local/bin/nvim"
}

install_linux_font() {
    local dir="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
    if [ -d "$dir" ]; then info "JetBrainsMono Nerd Font already installed"; return; fi
    info "Installing JetBrainsMono Nerd Font into ~/.local/share/fonts"
    mkdir -p "$dir"
    curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz" \
        | tar -xJ -C "$dir"
    fc-cache -f >/dev/null 2>&1 || true
}

install_linux_packages() {
    if ! command -v apt-get >/dev/null 2>&1; then
        warn "apt-get not found; skipping packages (only Debian/Ubuntu are supported)"
        return
    fi
    info "Installing apt packages from packages/apt.txt"
    local pkgs
    pkgs="$(sed -e 's/#.*//' -e '/^[[:space:]]*$/d' "$DOTFILES/packages/apt.txt" | tr '\n' ' ')"
    sudo apt-get update
    # shellcheck disable=SC2086
    sudo apt-get install -y $pkgs

    # Not in every release's repositories, so a failure here is not fatal.
    sudo apt-get install -y lazygit || warn "lazygit is not in apt on this release; see https://github.com/jesseduffield/lazygit#installation"

    # Debian/Ubuntu ship fd as "fdfind"
    mkdir -p "$HOME/.local/bin"
    if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
        ln -sfn "$(command -v fdfind)" "$HOME/.local/bin/fd"
    fi

    install_linux_neovim

    # On WSL the terminal and its font live on the Windows side (install.ps1).
    if [ "$OS" = linux ]; then
        sudo apt-get install -y alacritty || warn "alacritty is not in apt on this release; see https://alacritty.org"
        install_linux_font
    fi
}

if [ "$PACKAGES" = 1 ]; then
    if [ "$OS" = macos ]; then install_macos_packages; else install_linux_packages; fi
else
    info "Skipping packages (--no-packages)"
fi

# --- Symlinks ---------------------------------------------------------------
# link <path inside repo> <target path>
link() {
    local src="$DOTFILES/$1" dst="$2"
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        echo "  ok       $dst"
        return
    fi
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        backup "$dst"
    fi
    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    echo "  linked   $dst -> $src"
}

# Move a file out of the way, keeping its path relative to $HOME.
backup() {
    local path="$1" dest
    dest="$BACKUP/${path#"$HOME"/}"
    mkdir -p "$(dirname "$dest")"
    mv "$path" "$dest"
    echo "  backup   $path -> $dest"
}

info "Linking configs"
link bash/bashrc        "$HOME/.bashrc"
link bash/bash_profile  "$HOME/.bash_profile"
link tmux/tmux.conf     "$HOME/.config/tmux/tmux.conf"
link nvim               "$HOME/.config/nvim"
if [ "$OS" != wsl ]; then
    link alacritty/alacritty.toml "$HOME/.config/alacritty/alacritty.toml"
fi

# The config now lives in ~/.config/tmux; an old ~/.tmux.conf would shadow it.
if [ -e "$HOME/.tmux.conf" ] || [ -L "$HOME/.tmux.conf" ]; then
    backup "$HOME/.tmux.conf"
fi

# --- tmux plugins -----------------------------------------------------------
TPM="$HOME/.tmux/plugins/tpm"
if command -v tmux >/dev/null 2>&1 && command -v git >/dev/null 2>&1; then
    if [ ! -d "$TPM" ]; then
        info "Installing tmux plugin manager (TPM)"
        git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM"
    fi
    info "Installing tmux plugins"
    TMUX_PLUGIN_MANAGER_PATH="$HOME/.tmux/plugins/" "$TPM/bin/install_plugins" \
        || warn "could not install tmux plugins; open tmux and press prefix + I"
else
    warn "tmux or git not installed; skipping tmux plugins"
fi

info "Done."
if [ -d "$BACKUP" ]; then
    echo "Previous files were moved to $BACKUP"
fi
echo "Open a new terminal to pick up the bash config. Neovim installs its plugins on first start."
