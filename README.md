# dotfiles

Personal configuration files for shell, git, terminal, tmux, and Claude Code.

## Contents

| File | Description |
|------|-------------|
| `zshrc` | Zsh configuration with Zinit, lazy loading, aliases |
| `p10k.zsh` | Powerlevel10k prompt theme |
| `tmux.conf` | Tmux configuration with Catppuccin Mocha theme, vim-style bindings, TPM plugins |
| `gitconfig` | Git configuration with aliases and signing (add your own `[user]` section) |
| `gitignore` | Global gitignore patterns |
| `gitmessage` | Git commit message template |
| `ghostty_config` | Ghostty terminal configuration |
| `.claude/` | Claude Code configuration |
| `.codex/config.toml` | OpenAI Codex CLI configuration |
| `.config/opencode/opencode.json` | OpenCode configuration |

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

# For Codex CLI
mkdir -p ~/.codex
ln -sf ~/dotfiles/.codex/config.toml ~/.codex/config.toml

# For OpenCode
mkdir -p ~/.config/opencode
ln -sf ~/dotfiles/.config/opencode/opencode.json ~/.config/opencode/opencode.json
```

After symlinking, add your git identity and signing key to `~/.gitconfig` (required since `gpgsign = true`):

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
git config --global user.signingkey ~/.ssh/your_signing_key.pub
```

## Claude Code Configuration

### Files

| File | Description |
|------|-------------|
| `.claude/CLAUDE.md` | Custom instructions for Claude |
| `.claude/settings.json` | Permissions, plugins, and settings |
| `.claude/statusline-command.sh` | Custom statusline with git info |
| `.claude/output-styles/` | Custom output style prompts |

## License

MIT
