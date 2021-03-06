# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/home/pushkar/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	git
	zsh-autosuggestions
	zsh-syntax-highlighting
	tmux
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

export EDITOR='vim'
if test $(which nvim); then
  alias vim=nvim
  alias vimdiff='nvim -d'

  # Preferred editor for local and remote sessions
  if [[ $SSH_CONNECTION ]]; then
    export EDITOR='nvim'
  fi
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

# Aliases

# ZSH and P10K
alias zshconfig="code ~/.zshrc"
alias ohmyzsh="code ~/.oh-my-zsh"
alias updp10k="git -C $ZSH_CUSTOM/themes/powerlevel10k pull"
alias loadzsh="source ~/.zshrc"

# System Commands
alias bye="exit"
alias :q="exit"
alias cls="clear"
alias cpv="rsync -avhW --no-compress --progress"
alias greph="history | grep"
alias grepv="grep -HIrn"
alias grepc="grep -c"
alias diff="diff -u --color=always"

# Ubuntu Commands
alias upd="sudo apt update"
alias upg="sudo apt upgrade"
alias updg="sudo apt update && sudo apt upgrade"
alias instl="sudo apt install"
alias rmv="sudo apt remove"
alias upgls="sudo apt list --upgradable"
alias autorm="sudo apt autoremove"
alias autocln="sudo apt autoclean"

# Get WiFi keys
alias wifikey="sudo grep -r '^psk=' /etc/NetworkManager/system-connections/"

# Python
alias pyup="python setup.py sdist bdist_wheel && twine upload dist/*"
alias pir="pip install -r requirements.txt"
alias pipi="pip install"
alias pipu="pip uninstall"

# MATLAB
alias matlabt="matlab -nodesktop -nosplash"
alias matlab-drive="~/bin/MATLABConnector toggle"

# tmux
alias t="_zsh_tmux_plugin_run -u"

# nvim
alias nvplugi="nvim -c :PlugInstall"

# Functions

# MATLAB
matlab-run() {
    echo "Running MATLAB..."
    matlab -nodesktop -nosplash -r "$1"
}

# Change Directory and open in VSCode
ccd() {
    cd "$1" && code .
}

# C and C++
cpp-run() {
    echo "Compiling file..."
    g++ -o "$1" "$1.cpp"
    echo "Compiled!"
    ./"$1"
}
c-run() {
    echo "Compiling file..."
    gcc -o "$1" "$1.c"
    echo "Compiled!"
    ./"$1"
}

# Convert gif to webm format
gif2webm() {
    ffmpeg -i $1.gif -c vp9 -b:v 0 -crf 41 $1.webm
}

# Short GitHub url
gurl() {
    curl -i https://git.io -F "url=$1" \
    -F "code=$2"
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# vi keybind
bindkey -v

# Github CLI completion
eval "$(gh completion -s zsh)"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/pushkar/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/pushkar/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/pushkar/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/pushkar/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

