# dotfiles

Personal configuration files for shell, git, terminal, tmux, and Claude Code.

## Contents

| File | Description |
|------|-------------|
| `zshrc` | Zsh configuration with Zinit, lazy loading, aliases |
| `p10k.zsh` | Powerlevel10k prompt theme |
| `tmux.conf` | Tmux configuration with Catppuccin Mocha theme, vim-style bindings, TPM plugins |
| `gitconfig` | Git configuration with aliases and signing |
| `gitignore` | Global gitignore patterns |
| `gitmessage` | Git commit message template |
| `ghostty_config` | Ghostty terminal configuration |
| `.claude/` | Claude Code configuration |

## Installation

```bash
# Clone the repo
git clone https://github.com/thepushkarp/dotfiles ~/dotfiles

# Symlink configs
ln -sf ~/dotfiles/zshrc ~/.zshrc
ln -sf ~/dotfiles/p10k.zsh ~/.p10k.zsh
ln -sf ~/dotfiles/tmux.conf ~/.tmux.conf
ln -sf ~/dotfiles/gitconfig ~/.gitconfig
ln -sf ~/dotfiles/gitignore ~/.gitignore
ln -sf ~/dotfiles/gitmessage ~/.gitmessage

# For Ghostty
ln -sf ~/dotfiles/ghostty_config "~/Library/Application Support/com.mitchellh.ghostty/config"

# For Claude Code
ln -sf ~/dotfiles/.claude ~/.claude
```

## Claude Code Configuration

### Files

| File | Description |
|------|-------------|
| `.claude/CLAUDE.md` | Custom instructions for Claude |
| `.claude/settings.json` | Permissions, plugins, and settings |
| `.claude/statusline-command.sh` | Custom statusline with git info |
| `.claude/output-styles/` | Custom output style prompts |
| `.claude/hooks/session-start.sh` | SessionStart hook for project setup |

### SessionStart Hook

The `session-start.sh` hook automatically sets up your development environment when starting a Claude Code session.

#### Features

- **Remote-only dependency installation**: Only runs heavy setup in Claude Code on the Web
- **Python support**: Uses `uv` to sync dependencies from `pyproject.toml` or `requirements.txt`
- **Node/Frontend support**: Uses `yarn` (or `npm`) to install from `package.json`
- **Git context**: Shows current branch, recent commits, and uncommitted changes
- **TODO loading**: Displays active TODOs if `TODO.md` exists

#### Usage

To use this hook in your projects, add to your project's `.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/session-start.sh"
          }
        ]
      }
    ]
  }
}
```

Then copy the hook script to your project:

```bash
mkdir -p .claude/hooks
cp ~/dotfiles/.claude/hooks/session-start.sh .claude/hooks/
chmod +x .claude/hooks/session-start.sh
```

#### Customization

The hook checks `CLAUDE_CODE_REMOTE` to determine if running in Claude Code on the Web:

```bash
if [ "$CLAUDE_CODE_REMOTE" = "true" ]; then
  # Only runs in web environment
fi
```

To persist environment variables for the session, write to `CLAUDE_ENV_FILE`:

```bash
echo 'export MY_VAR=value' >> "$CLAUDE_ENV_FILE"
```

## License

MIT
