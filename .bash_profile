alias ls='ls -GFh'
 
# Git aliases
 
alias gif='git fetch' # Fetch from a repo
alias gis='git status' # Current status
alias gid='git diff' # Show differences
alias gia='git add -A' # Add all files to scope
alias gich='git checkout $1' # Change to branch X
alias gib='git checkout -b $1' # Make and switch to branch X
 
# Function for git add, commit and push
# Note: Commits ALL files in working directory.
# Usage: gic [commit message]
gic () {
        git add -A
        git commit -m "$1"
}
