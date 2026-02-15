# Performance profiling (uncomment to measure startup time)
# zmodload zsh/zprof

# Enable zsh optimizations
setopt AUTO_CD              # cd by typing directory name if it's not a command
setopt AUTO_LIST            # automatically list choices on ambiguous completion
setopt AUTO_MENU            # automatically use menu completion
setopt ALWAYS_TO_END        # move cursor to end if word had one match
setopt HIST_VERIFY          # show command with history expansion to user before running it
setopt SHARE_HISTORY        # share command history data
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

# Auto-attach to tmux on SSH connections
if [[ -n "$SSH_CONNECTION" && -z "$TMUX" ]]; then
  exec tmux
fi

# Only enable full prompt stack when shell has a real TTY.
typeset -gi HAS_PROMPT_TTY=0
if [[ -o interactive && -t 0 && -t 1 ]]; then
  HAS_PROMPT_TTY=1
fi

# Enable Powerlevel10k instant prompt (must be near top)
if (( HAS_PROMPT_TTY )) && [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Initialize completion system ONCE with smart caching
autoload -Uz compinit
typeset -i updated_at=$(date +'%j' -r ~/.zcompdump 2>/dev/null || stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)
if [ $(date +'%j') != $updated_at ]; then
  compinit -i
else
  compinit -C -i
fi

# Initialize Zinit with optimized settings
declare -A ZINIT
ZINIT[HOME_DIR]="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit"
ZINIT[ZCOMPDUMP_PATH]="${XDG_CACHE_HOME:-$HOME/.cache}/.zcompdump"

# Create zinit directory if it doesn't exist
if [[ ! -d "${ZINIT[HOME_DIR]}" ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing ZDHARMA-CONTINUUM Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "${ZINIT[HOME_DIR]}" && command chmod g-rwX "${ZINIT[HOME_DIR]}"
    command git clone https://github.com/zdharma-continuum/zinit "${ZINIT[HOME_DIR]}/zinit.git" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "${ZINIT[HOME_DIR]}/zinit.git/zinit.zsh"

# Load Powerlevel10k theme first for instant prompt
if (( HAS_PROMPT_TTY )); then
    zinit ice depth=1
    zinit light romkatv/powerlevel10k
fi

# Define essential functions early
function omz_urlencode() {
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:$i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            ' ') printf "+" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done
}

# Essential OMZ libraries - load synchronously for core functionality
zinit wait lucid for \
    OMZL::git.zsh \
    OMZL::history.zsh \
    OMZL::completion.zsh \
    OMZL::directories.zsh

# Load remaining OMZ libraries in turbo mode
zinit wait"1" lucid for \
    OMZL::clipboard.zsh \
    OMZL::theme-and-appearance.zsh \
    OMZL::termsupport.zsh

# Core plugins - load immediately but with turbo
zinit wait lucid for \
    OMZP::git \
    OMZP::colored-man-pages

# Secondary plugins - defer loading
zinit wait"2" lucid for \
    OMZP::pip \
    OMZP::python \
    OMZP::brew

# Syntax highlighting and completions - load with proper timing
zinit wait lucid for \
    atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
        zdharma-continuum/fast-syntax-highlighting \
    blockf \
        zsh-users/zsh-completions \
    atload"!_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions

# ============================================================================
# ENVIRONMENT VARIABLES
# ============================================================================

# Editor configuration
export EDITOR='cursor'
export VISUAL='cursor'

# History configuration
export HISTSIZE=50000
export SAVEHIST=10000
export HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"

# Cache directory for completions
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d "$ZSH_CACHE_DIR" ]] || mkdir -p "$ZSH_CACHE_DIR"

# ============================================================================
# PATH OPTIMIZATION
# ============================================================================

# Function to add to PATH only if directory exists and not already in PATH
function add_to_path() {
    local dir="$1"
    if [[ -d "$dir" && ":$PATH:" != *":$dir:"* ]]; then
        export PATH="$dir:$PATH"
    fi
}

# Core system paths
add_to_path "/Library/TeX/texbin"
add_to_path "/opt/homebrew/bin"
add_to_path "/opt/homebrew/sbin"

# Development tool paths
typeset -a dev_paths=(
    "$HOME/.local/bin"
    "$HOME/.bun/bin"
    "$HOME/.yarn/bin"
    "$HOME/.config/yarn/global/node_modules/.bin"
    "$HOME/.deta/bin"
    "$HOME/.cache/lm-studio/bin"
    "$HOME/.codeium/windsurf/bin"
    "$HOME/.atuin/bin/env"
)

for path_entry in "${dev_paths[@]}"; do
    add_to_path "$path_entry"
done

# Go path
if command -v go >/dev/null 2>&1; then
    add_to_path "${GOPATH:-$HOME/go}/bin"
fi

# ============================================================================
# ENVIRONMENT SETUP
# ============================================================================

# Java setup
if [[ -d "/opt/homebrew/opt/openjdk" ]]; then
    export JAVA_HOME="/opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home"
    add_to_path "$JAVA_HOME/bin"

    # Hadoop setup (only if Java is available)
    local hadoop_dir="/opt/homebrew/Cellar/hadoop"
    if [[ -d "$hadoop_dir" ]]; then
        # Find the latest hadoop version dynamically
        local hadoop_version=$(ls "$hadoop_dir" | sort -V | tail -n1)
        export HADOOP_HOME="$hadoop_dir/$hadoop_version/libexec"
        export HADOOP_CONF_DIR="$HADOOP_HOME/etc/hadoop"
        export HADOOP_MAPRED_HOME="$HADOOP_HOME"
        export HADOOP_COMMON_HOME="$HADOOP_HOME"
        export HADOOP_HDFS_HOME="$HADOOP_HOME"
        export YARN_HOME="$HADOOP_HOME"
        export HADOOP_COMMON_LIB_NATIVE_DIR="$HADOOP_HOME/lib/native"
        export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib"
        export HADOOP_CLASSPATH="$JAVA_HOME/lib/tools.jar"
        add_to_path "$HADOOP_HOME/bin"
        add_to_path "$HADOOP_HOME/sbin"
    fi
fi

# OpenSSL setup
if [[ -d "/opt/homebrew/opt/openssl@3" ]]; then
    add_to_path "/opt/homebrew/opt/openssl@3/bin"
    export LDFLAGS="-L/opt/homebrew/opt/openssl@3/lib $LDFLAGS"
    export CPPFLAGS="-I/opt/homebrew/opt/openssl@3/include $CPPFLAGS"
    export PKG_CONFIG_PATH="/opt/homebrew/opt/openssl@3/lib/pkgconfig:$PKG_CONFIG_PATH"
fi

# Docker completions (only if Docker is installed)
if [[ -d "/Users/pupa/.docker/completions" ]]; then
    fpath=(/Users/pupa/.docker/completions $fpath)
fi

# Ollama configuration
export OLLAMA_API_BASE="http://127.0.0.1:11434"
export OLLAMA_FLASH_ATTENTION=1
export OLLAMA_KV_CACHE_TYPE=q8_0

# ============================================================================
# LAZY LOADING OPTIMIZATIONS
# ============================================================================

# NVM lazy loading function
if [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]]; then
    export NVM_DIR="$HOME/.nvm"

    # Create lazy loading wrapper for nvm command only
    nvm() {
        unset -f nvm
        source "/opt/homebrew/opt/nvm/nvm.sh"
        [[ -r "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ]] && source "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
        nvm "$@"
    }

    # Helper function to quickly switch to project-specific Node version
    nvmuse() {
        if [[ -f ".nvmrc" ]]; then
            nvm use
        else
            echo "No .nvmrc file found in current directory"
            echo "Available Node versions:"
            nvm list
        fi
    }
fi

# SDKMAN lazy loading
if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    export SDKMAN_DIR="$HOME/.sdkman"
    sdk() {
        unset -f sdk
        source "$HOME/.sdkman/bin/sdkman-init.sh"
        sdk "$@"
    }
fi

# ============================================================================
# TOOL INITIALIZATION
# ============================================================================

# Initialize tools directly

# Atuin initialization
if (( HAS_PROMPT_TTY )) && command -v atuin >/dev/null 2>&1; then
    eval "$(atuin init zsh)"
fi

# FZF integration (Ctrl+R history, Ctrl+T files, Alt+C dirs)
if (( HAS_PROMPT_TTY )) && [[ -f ~/.fzf.zsh ]]; then
    source ~/.fzf.zsh
fi

# Thefuck - lazy loaded (press ESC ESC after a mistake)
fuck() {
    unfunction fuck
    eval "$(thefuck --alias)"
    fuck "$@"
}

# Ngrok lazy loading
ngrok() {
    unset -f ngrok
    if command -v ngrok >/dev/null 2>&1; then
        eval "$(command ngrok completion)"
    fi
    command ngrok "$@"
}

# Bun completions
if (( HAS_PROMPT_TTY )) && [[ -s "$HOME/.bun/_bun" ]]; then
    source "$HOME/.bun/_bun"
fi

# ============================================================================
# ALIASES
# ============================================================================

# System aliases
alias cls="clear"
alias bye="exit"
alias ll="ls -la"
alias la="ls -A"
alias l="ls -CF"
alias insomnia="sudo pmset -a disablesleep 1"
alias sleepy="sudo pmset -a disablesleep 0"

# Configuration aliases
alias zshconfig="$EDITOR ~/.zshrc"
alias zshreload="source ~/.zshrc && echo 'ZSH config reloaded!'"

# Git aliases
alias treeg="git ls-tree -r --name-only HEAD | tree --fromfile"

# Development aliases
alias edit-claude-mcp='$EDITOR "$HOME/Library/Application Support/Claude/claude_desktop_config.json"'
alias edit-ghostty='$EDITOR "$HOME/Library/Application Support/com.mitchellh.ghostty/config"'

# Hadoop aliases (conditional)
if [[ -n "$HADOOP_HOME" ]]; then
    alias hstart="$HADOOP_HOME/sbin/start-all.sh"
    alias hstop="$HADOOP_HOME/sbin/stop-all.sh"
fi

# Performance aliases
alias zsh-bench="for i in {1..10}; do /usr/bin/time zsh -i -c exit; done"
alias zsh-prof="zsh -i -c 'zprof | head -20'"

# ============================================================================
# FUNCTIONS
# ============================================================================

# Enhanced directory functions
function mkcd() {
    mkdir -p "$@" && cd "$_"
}

function cdls() {
    cd "$1" && ls
}

# Performance testing function
function zsh_startup_time() {
    local total=0
    local iterations=${1:-5}
    echo "Testing ZSH startup time ($iterations iterations)..."

    for i in $(seq 1 $iterations); do
        local time_result=$(/usr/bin/time -p zsh -i -c exit 2>&1 | grep real | awk '{print $2}')
        total=$(echo "$total + $time_result" | bc -l)
        echo "Run $i: ${time_result}s"
    done

    local average=$(echo "scale=3; $total / $iterations" | bc -l)
    echo "Average startup time: ${average}s"
}

# Quick profiling function
function zsh_profile() {
    zsh -i -c 'zmodload zsh/zprof; zprof | head -20'
}

# ============================================================================
# FINAL SETUP
# ============================================================================

# Load p10k configuration
if (( HAS_PROMPT_TTY )) && [[ -f ~/.p10k.zsh ]]; then
    source ~/.p10k.zsh
fi

# Clean up functions
unset -f add_to_path

# Zoxide initialization
if (( HAS_PROMPT_TTY )) && command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
    alias cd=z
fi

# Added by Antigravity
export PATH="/Users/pupa/.antigravity/antigravity/bin:$PATH"

# opencode
export PATH=/Users/pupa/.opencode/bin:$PATH

# bun completions
if (( HAS_PROMPT_TTY )) && [[ -s "/Users/pupa/.bun/_bun" ]]; then
    source "/Users/pupa/.bun/_bun"
fi

unset HAS_PROMPT_TTY

# Performance profiling output (uncomment to see results)
# zprof
