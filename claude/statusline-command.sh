#!/bin/bash

# Read input JSON
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')

# Session info for duration calculation
session_id=$(echo "$input" | jq -r '.session_id')
session_file="/tmp/claude_session_${session_id}"
if [ ! -f "$session_file" ]; then
    date +%s > "$session_file" 2>/dev/null
fi
session_start=$(cat "$session_file" 2>/dev/null || echo "$(date +%s)")
current_time=$(date +%s)
session_duration=$((current_time - session_start))
session_minutes=$((session_duration / 60))

# Directory info - show parent/current (like p10k)
dir_path="${cwd/#$HOME/\~}"

if [ "$dir_path" = "~" ]; then
    dir="~"
else
    # Get parent and current folder
    current=$(basename "$dir_path")
    parent=$(basename "$(dirname "$dir_path")")
    if [ "$parent" = "~" ] || [ "$parent" = "/" ]; then
        dir="$current"
    else
        dir="$parent/$current"
    fi
fi

# Git info
git_info=""
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git -C "$cwd" branch --show-current 2>/dev/null || echo "detached")
    # Check if there are changes
    if ! git -C "$cwd" -c core.useBuiltinFSMonitor=false diff-index --quiet HEAD -- 2>/dev/null; then
        git_info=$(printf " \033[38;5;220m🌿 %s\033[0m" "$branch")
    else
        git_info=$(printf " \033[38;5;76m🌿 %s\033[0m" "$branch")
    fi
fi

# Build status line string
status_line=""

# Directory in blue
status_line="${status_line}$(printf "\033[38;5;39m📁 %s\033[0m" "$dir")"

# Git branch
status_line="${status_line}${git_info}"

# Model info in cyan
status_line="${status_line}   $(printf "\033[38;5;39m🤖 %s\033[0m" "$model")"

# Time - color 242 (gray)
status_line="${status_line}   $(printf "\033[38;5;242m🕐 %s\033[0m" "$(date +%H:%M)")"

# Battery level (macOS) - color 220 (yellow)
if command -v pmset >/dev/null 2>&1; then
    battery_pct=$(pmset -g batt 2>/dev/null | grep -Eo "[0-9]+%" | head -n1 | tr -d '%')
    if [ -n "$battery_pct" ]; then
        status_line="${status_line}   $(printf "\033[38;5;220m🔋 %s%%\033[0m" "$battery_pct")"
    fi
fi

# Token count from context window - color 141 (purple)
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
if [ "$total_input" != "0" ] || [ "$total_output" != "0" ]; then
    total_tokens=$((total_input + total_output))
    if [ "$total_tokens" -ge 1000 ]; then
        tokens_display=$(awk "BEGIN {printf \"%.1fk\", $total_tokens/1000}")
    else
        tokens_display="$total_tokens"
    fi
    status_line="${status_line}   $(printf "\033[38;5;141m⚡ %s\033[0m" "$tokens_display")"
fi

# Session duration - color 242 (gray)
status_line="${status_line}   $(printf "\033[38;5;242m⏱️ %dm\033[0m" "$session_minutes")"

# Output everything on ONE line with no trailing newline
printf "%s" "$status_line"
