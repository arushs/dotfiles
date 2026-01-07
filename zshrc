# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/arushshankar/.oh-my-zsh"
  export PATH="$PATH:/Users/arushshankar/.local/bin"
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

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
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

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
plugins=( git z )

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

alias gs='git status'

alias gcz='git-cz'

alias gn='git commit --amend --no-edit'

alias gcwip='git commit -m"wip" --no-verify'

alias grim='git rebase -i master'

alias gpf='git push -f'

alias be='bundle exec'

alias dc='docker-compose'

alias dc-bash='docker compose exec -- web /bin/bash'
alias dc-restart='dc restart'

alias gap='git add --patch'

alias gfr='git fetch && git rebase master --autostash'

alias dcd='dc down'

alias dcu='dc up -d'

alias gb='git branch -v'

export EDITOR=code

alias be="bundle exec"

alias _gmainbranch="git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'"
function deletepruned() {
  local mainbranch=$(_gmainbranch)
  git branch --merged "$mainbranch" | grep -v "* $mainbranch" | xargs -n 1 git branch -d
}

alias ls="exa"
alias cat="bat"

alias k=kubectl
alias gr="git restore"
function rebase_master() {
    # Get the current branch name
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

    # Check if there are any changes (staged/unstaged/untracked) to stash
    if [[ -n $(git status --porcelain) ]]; then
        echo "Changes detected, stashing them including untracked files..."
        git stash push --include-untracked
        STASHED=true
    else
        echo "No changes detected."
        STASHED=false
    fi

    # Checkout and fetch master
    git fetch
    git fetch origin master:master


    # Checkout the initial branch and rebase off of master
    git rebase master

    # Unstash changes if they were stashed earlier
    if [ "$STASHED" = true ]; then
        echo "Unstashing changes..."
        git stash pop
    fi

    echo "Done!"
}


alias rbm="rebase_master"
export PATH="/opt/homebrew/opt/openssl@3/bin:$PATH"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
USE_GKE_GCLOUD_AUTH_PLUGIN=True
. /opt/homebrew/opt/asdf/libexec/asdf.sh
alias grs=git restore --staged .

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/arushshankar/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/arushshankar/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/arushshankar/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/arushshankar/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

. /opt/homebrew/opt/asdf/libexec/asdf.sh
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
export BAT_THEME="Dracula"
alias gsw='git switch'


alias ghprc='gh pr create -a @me --fill-verbose'

alias ghd='gh dash'

export PATH="/opt/homebrew/opt/mysql@8.4/bin:$PATH"

# SENSITIVE CREDENTIALS - Set these in a separate local file or environment
# export JFROG_KEY="your-jfrog-key-here"

# export BUILDKITE_API_TOKEN="your-buildkite-token-here"

fix_lfs() {
git rm --cached -r .
git reset --hard
git rm .gitattributes
git reset .
git checkout .
}

# export GITHUB_API_KEY="your-github-api-key-here"

source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

alias claude="/Users/arushshankar/.claude/local/claude"

# bun completions
[ -s "/Users/arushshankar/.bun/_bun" ] && source "/Users/arushshankar/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
