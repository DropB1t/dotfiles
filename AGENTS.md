# AGENTS.md

Personal dotfiles managed with **GNU Stow**. Each top-level directory is a stow package whose internal tree mirrors `$HOME` (e.g. `ghostty/.config/ghostty/config` → `~/.config/ghostty/config`, `git/.gitconfig` → `~/.gitconfig`). There is no build, lint, or CI; `test_zsh.sh` validates the Zsh package.

## Commands

- `./stow_all.sh` — stow every package into `~/` (auto-globs top-level dirs, so new packages need no registration).
- Single package: `stow -v --no-folding -t ~/ -S <pkg>` (`-R` restow, `-D` unstow).
- Dry-run to verify before applying: add `-n` (e.g. `stow -n -v --no-folding -t ~/ -S zsh`).
- `./install` / `./uninstall` — install or remove the Zsh package with Stow; history and plugin data are preserved on uninstall.
- `./test_zsh.sh` — check syntax, XDG bootstrap, isolated startup without optional dependencies, and startup time.
- `./configure_machine.sh` — Ubuntu/Debian/WSL-only bootstrap (apt packages, native Zsh config, ghostty, yazi, delta, GNOME tweaks on GUI). Exits on other distros.

## Conventions & gotchas

- **Always pass `--no-folding` to stow.** It is deliberate (dedicated commit): it makes stow create real directories instead of symlinking whole dirs, so apps writing into their config dirs don't write into this repo.
- Adding config for a new tool = create a new top-level package dir mirroring the tool's real path under `$HOME` (not always `.config` — see `git/`).
- The Zsh package is XDG-compliant: `zsh/.zshenv` sets `ZDOTDIR`, while interactive configuration mirrors `~/.config/zsh/` under `zsh/.config/zsh/`.
- Keep `.zshenv` minimal because every Zsh invocation reads it. Interactive options, completion, keybindings, prompt, and plugins belong in `.config/zsh/.zshrc` or its sourced modules.
- `./install` pins and installs `zsh-autosuggestions` and `zsh-syntax-highlighting` under `$XDG_DATA_HOME/zsh/plugins`; configuration must still start when they or `fzf` are absent.
- Tracked zsh configs must not contain absolute home paths (`/home/<user>/...`) — use `$HOME` (or the relevant var, e.g. `$GOPATH`). Machine-specific env values belong in `~/.env.zsh`, which is sourced directly and is not tracked here.
- `*.ttc` files are tracked via **Git LFS** (`.gitattributes`, `filter "lfs" required = true` in the stowed `.gitconfig`). Currently there is no fonts package, but git-lfs must be installed before adding new font files.
- Stow conflicts: if a target file already exists in `~/` and isn't a stow symlink, Stow refuses — remove or back up the existing file first. The Zsh installer removes only obsolete links that resolve into this repository.

## Style

- Shell scripts target bash/zsh on Ubuntu; keep them POSIX-ish where trivial, matching existing style (tabs in `.sh`, existing quoting patterns).
- Commit messages use Conventional Commits (`feat(zsh): ...`, `chore(stow): ...`) — see git log.
