# dotfiles

Personal dotfiles managed with **GNU Stow**. Each top-level directory is a stow package whose internal tree mirrors `$HOME`.

## Packages

| Package   | Target                                |
|-----------|---------------------------------------|
| alacritty | `~/.config/alacritty/`                |
| btop      | `~/.config/btop/`                     |
| fastfetch | `~/.config/fastfetch/`                |
| ghostty   | `~/.config/ghostty/`                  |
| git       | `~/.gitconfig`, `~/.gitignore_global` |
| htop      | `~/.config/htop/`                     |
| zsh       | `~/.zshenv` + `~/.config/zsh/`        |

## Usage

```sh
# Stow every package
./dot_scripts/stow_all.sh

# Stow / restow / unstow a single package
stow -v --no-folding -t ~/ -S <pkg>   # -R restow, -D unstow

# Dry-run first
stow -n -v --no-folding -t ~/ -S <pkg>
```

Install/remove just the Zsh package (preserves history and plugin data):

```sh
./dot_scripts/install_zsh.sh
./dot_scripts/uninstall_zsh.sh
```

Validate the Zsh package (syntax, XDG bootstrap, isolated startup, startup time):

```sh
./dot_scripts/test_zsh.sh
```

Ubuntu/Debian/WSL-only bootstrap (apt packages, native Zsh config, ghostty, yazi, delta, GNOME tweaks):

```sh
./dot_scripts/configure_machine.sh
```

## Notes

- **Always pass `--no-folding`** to stow — real directories are created instead of symlinked whole dirs, so apps don't write into this repo.
- Add config for a new tool by creating a top-level package mirroring the tool's real path under `$HOME` (not always `.config` — see `git/`).
- Zsh is XDG-compliant: `zsh/.zshenv` sets `ZDOTDIR`; interactive config lives under `zsh/.config/zsh/` and is sourced from `.zshrc`. Config must still start when `fzf` or the pinned plugins (`zsh-autosuggestions`, `zsh-syntax-highlighting`) are absent.
- Tracked zsh configs must not contain absolute home paths — use `$HOME` (or e.g. `$GOPATH`); machine-specific env belongs in untracked `~/.env.zsh`.
- `*.ttc` files are tracked via **Git LFS**; install git-lfs before adding font files.
- Stow refuses on target conflicts — remove or back up the existing file first.
- `dot_scripts/` is a helper directory, not a stow package — it is skipped by `stow_all.sh` and never stowed into `$HOME`.

See `AGENTS.md` for the full contributor guide and `LICENSE` for licensing.
