#!/usr/bin/env bash
# Refresh the package list for the OS this is run on.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

case "$(uname -s)" in
    Darwin)
        brew bundle dump --force --file Brewfile
        echo "Updated packages/Brewfile"
        ;;
    Linux)
        # Everything you installed by hand on this machine. Kept separate from
        # apt.txt (the curated list install.sh uses) so you can pick from it.
        apt-mark showmanual | sort > apt-manual.txt
        echo "Wrote packages/apt-manual.txt ($(wc -l < apt-manual.txt) packages)"
        echo "Copy the ones you want on every machine into packages/apt.txt"
        ;;
    *)
        echo "Unsupported OS: $(uname -s)" >&2
        exit 1
        ;;
esac
