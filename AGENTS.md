# AGENTS.md

Personal dotfiles managed with **GNU Stow**. Each top-level directory is a stow package whose internal tree mirrors `$HOME` (e.g. `ghostty/.config/ghostty/config` → `~/.config/ghostty/config`, `git/.gitconfig` → `~/.gitconfig`). There is no build, test, lint, or CI.

## Commands

- `./stow_all.sh` — stow every package into `~/` (auto-globs top-level dirs, so new packages need no registration).
- Single package: `stow -v --no-folding -t ~/ -S <pkg>` (`-R` restow, `-D` unstow).
- Dry-run to verify before applying: add `-n` (e.g. `stow -n -v --no-folding -t ~/ -S zsh`). This is the only "test" that exists.
- `./configure_machine.sh` — Ubuntu/Debian/WSL-only bootstrap (apt packages, ghostty, yazi, delta, zsh4humans, GNOME tweaks on GUI). Exits on other distros.

## Conventions & gotchas

- **Always pass `--no-folding` to stow.** It is deliberate (dedicated commit): it makes stow create real directories instead of symlinking whole dirs, so apps writing into their config dirs don't write into this repo.
- Adding config for a new tool = create a new top-level package dir mirroring the tool's real path under `$HOME` (not always `.config` — see `git/`).
- `zsh/.zshrc` depends on **zsh4humans** (`z4h`), installed by `configure_machine.sh`; it fails on machines without it.
- `.zshrc` sources `~/.zsh.d/*.zsh` via an **explicit list** — dropping a new file into `zsh/.zsh.d/` does nothing until it's added to the `sources` array in `.zshrc`. Note `backup.zsh` exists but is intentionally not in the list.
- `zsh/.zsh.d/zsh-nvm/` is vendored third-party code (own LICENSE/README) — don't edit it as if it were first-party.
- Tracked zsh configs must not contain absolute home paths (`/home/<user>/...`) — use `$HOME` (or the relevant var, e.g. `$BUN_INSTALL`). Machine-specific env values belong in `~/.env.zsh`, which `.zshrc` sources via `z4h` and which is not tracked here.
- `*.ttc` files are tracked via **Git LFS** (`.gitattributes`, `filter "lfs" required = true` in the stowed `.gitconfig`). Currently there is no fonts package, but git-lfs must be installed before adding new font files.
- Stow conflicts: if a target file already exists in `~/` and isn't a stow symlink, stow refuses — remove/backup the existing file first (notably `~/.zshrc` created by the zsh4humans installer).

## Style

- Shell scripts target bash/zsh on Ubuntu; keep them POSIX-ish where trivial, matching existing style (tabs in `.sh`, existing quoting patterns).
- Commit messages use Conventional Commits (`feat(zsh): ...`, `chore(stow): ...`) — see git log.
