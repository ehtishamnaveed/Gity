# Gity

**A beautiful, keyboard-driven TUI hub for managing all your Git repositories in one place.**

No more hunting for repos across your filesystem. Gity automatically discovers all your Git repositories and brings them together in a fast, elegant fzf-powered interface.

![Gity Screenshot](docs/screenshot.png)

## Features

- **Auto-Discovery** — Scans your home directory and finds all Git repos automatically
- **Fuzzy Search** — Instantly filter through hundreds of repos with fzf
- **Recent First** — Your most-used repos always appear at the top
- **Clone & Create** — Clone new repos or create new ones from the app
- **Quick Actions** — Open in Lazygit, your default editor, or your file manager with one keypress
- **Smart Clipboard** — Copies repo paths when clipboard tools are available
- **Zero Config** — Works out of the box on Linux, macOS, and Windows (WSL / Git Bash)

## Requirements

- [lazygit](https://github.com/jesseduffield/lazygit) — The terminal UI for Git commands
- [fzf](https://github.com/junegunn/fzf) — Fuzzy finder for the interface
- `git` — Version control
- A way to open directories — uses `$EDITOR`, `xdg-open`, or platform defaults
- A clipboard tool (`xclip`, `xsel`, `wl-copy`, or Windows `clip`) — optional, for copy functionality

## Installation

### One-Line Install (All Platforms)

```bash
bash <(curl -sL https://github.com/ehtishamnaveed/gity/install.sh)
```

That's it. One command. Works on Linux, macOS, and Windows (WSL / Git Bash).

The installer will:
- Auto-detect your system
- Install `git`, `fzf`, and `lazygit` automatically
- Install Gity to `~/.local/bin/gity`
- Set up your PATH

### Prerequisites for Windows

Since Gity is a bash script, Windows users need **WSL** or **Git Bash** installed first:

- **WSL (recommended):** Open PowerShell and run `wsl --install`, then restart your PC
- **Git Bash:** Download from [git-scm.com](https://git-scm.com/downloads)

After that, run the one-liner above and Gity will install everything.

### Manual Install

```bash
# Linux / macOS
curl -sL https://github.com/ehtishamnaveed/gity/gity.sh -o ~/.local/bin/gity
chmod +x ~/.local/bin/gity

# Windows (WSL / Git Bash)
curl -sL https://github.com/ehtishamnaveed/gity/gity.sh -o ~/gity
chmod +x ~/gity
```

## Supported Platforms

### Linux

The installer auto-detects your distro and installs dependencies. Supported:
Arch Linux, Ubuntu/Debian, Fedora, OpenSUSE, Void Linux, and more.

### macOS

The installer uses Homebrew to install dependencies. Make sure [Homebrew](https://brew.sh) is installed first.

### Windows

Run the installer inside **WSL** or **Git Bash**. The installer handles everything else.

## Usage

Run Gity from your terminal:

```bash
gity
```

### Main Menu

| Option | Description |
|---|---|
| **Browse All Repositories** | Search and open an existing repo |
| **Clone Repository** | Clone a new repo from URL |
| **Create New Repository** | Initialize a new repo with an initial commit |
| **Exit** | Quit Gity |

### Repository Actions

After selecting a repo, you can:

| Action | Description |
|---|---|
| **Open in Lazygit (TUI)** | Launch lazygit in that repository |
| **Browse Files (fzf)** | Browse all repo files with fuzzy search and preview |
| **Open in Default Editor** | Open repo using your `$EDITOR`, or your system's default |
| **Open in File Manager** | Open repo folder in your file browser |
| **Copy Path to Clipboard** | Copy the repo path to your clipboard |

### Keyboard Navigation

- Use **arrow keys** or **vim-style (j/k)** to navigate
- Press **Enter** to select
- Press **Escape** or select empty to go back
- Type to **fuzzy search** filter the list

## How It Works

1. **First Run** — Gity scans your home directory for `.git` folders and builds a cache
2. **Caching** — Repo list is stored in `~/.cache/lazygit_repos` for fast access
3. **Recent Repos** — Your last 10 opened repos are tracked in `~/.cache/lazygit_recent`
4. **Smart Scanning** — Deep scan `~/Work`, `~/Plugins`, `~/Documents`, `~/Desktop`, `~/Luminor`, plus broad home scan (excluding cache directories)

## Configuration

Gity works with zero configuration, but you can customize:

| Variable | Default | Description |
|---|---|---|
| `REPO_DIR` | `~/Documents/Github` | Where cloned repos are saved |
| `CACHE_FILE` | `~/.cache/lazygit_repos` | Repo discovery cache |
| `RECENT_FILE` | `~/.cache/lazygit_recent` | Recently opened repos |

To override, edit `gity.sh` directly.

## Uninstall

```bash
rm ~/.local/bin/gity
rm ~/.cache/lazygit_repos
rm ~/.cache/lazygit_recent
```

Remove the PATH line from your `~/.bashrc` or `~/.zshrc` if added by the installer.

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

## License

MIT License — see [LICENSE](LICENSE) for details.

## Acknowledgments

- [lazygit](https://github.com/jesseduffield/lazygit) by Jesse Duffield
- [fzf](https://github.com/junegunn/fzf) by Junegunn Choi
