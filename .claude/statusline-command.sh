#!/bin/bash
# Claude Code Statusline - Helper Function Approach

# Read JSON input once
input=$(cat)

# Helper functions
get_model_name() { echo "$input" | jq -r '.model.display_name // "Unknown"'; }
get_current_dir() { echo "$input" | jq -r '.workspace.current_dir // "~"'; }
get_duration_ms() { echo "$input" | jq -r '.cost.total_duration_ms // 0'; }

# Get all current_usage tokens (input + output + cache)
get_current_context() {
    echo "$input" | jq -r '
        (.context_window.current_usage.input_tokens // 0) +
        (.context_window.current_usage.output_tokens // 0) +
        (.context_window.current_usage.cache_creation_input_tokens // 0) +
        (.context_window.current_usage.cache_read_input_tokens // 0)
    '
}

# Extract values
model_name=$(get_model_name)
dir_name=$(basename "$(get_current_dir)")
current_context=$(get_current_context)
duration_ms=$(get_duration_ms)

# Format context as k
if [ "$current_context" -ge 1000 ] 2>/dev/null; then
    current_k=$(awk "BEGIN {printf \"%.0f\", $current_context/1000}")k
else
    current_k="${current_context:-0}"
fi

# Format duration (ms to human readable)
if [ "$duration_ms" -gt 0 ] 2>/dev/null; then
    total_secs=$((duration_ms / 1000))
    if [ $total_secs -ge 3600 ]; then
        hours=$((total_secs / 3600))
        mins=$(((total_secs % 3600) / 60))
        duration_display="${hours}h${mins}m"
    elif [ $total_secs -ge 60 ]; then
        mins=$((total_secs / 60))
        secs=$((total_secs % 60))
        duration_display="${mins}m${secs}s"
    else
        duration_display="${total_secs}s"
    fi
else
    duration_display="0s"
fi

# Colors
C_DIR="\033[38;5;51m"         # Soft sky blue
C_MODEL="\033[38;5;105m"      # Soft pink/magenta
C_CONTEXT="\033[38;5;141m"    # Soft purple
C_DURATION="\033[38;5;220m"   # Soft yellow
C_GIT_CLEAN="\033[38;5;154m"  # Soft green
C_GIT_DIRTY="\033[38;5;222m"  # Soft peach/orange
C_SEP="\033[38;5;245m"        # Gray separator
C_RESET="\033[0m"

# Git info
git_branch="" && git_status="" && git_color="$C_GIT_CLEAN"
if git rev-parse --git-dir >/dev/null 2>&1; then
    git_branch=$(git --no-optional-locks branch --show-current 2>/dev/null || echo "detached")
    untracked=$(git --no-optional-locks ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
    staged=$(git --no-optional-locks diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
    modified=$(git --no-optional-locks diff --numstat 2>/dev/null | wc -l | tr -d ' ')
    ahead_behind=$(git --no-optional-locks rev-list --left-right --count @{upstream}...HEAD 2>/dev/null || echo "0 0")
    behind=$(echo "$ahead_behind" | awk '{print $1}') && ahead=$(echo "$ahead_behind" | awk '{print $2}')
    status_parts=""
    [ "$untracked" -gt 0 ] && status_parts="${status_parts}?${untracked}" && git_color="$C_GIT_DIRTY"
    [ "$staged" -gt 0 ] && status_parts="${status_parts:+$status_parts }+${staged}" && git_color="$C_GIT_DIRTY"
    [ "$modified" -gt 0 ] && status_parts="${status_parts:+$status_parts }!${modified}" && git_color="$C_GIT_DIRTY"
    [ "$ahead" -gt 0 ] && status_parts="${status_parts:+$status_parts }↑${ahead}"
    [ "$behind" -gt 0 ] && status_parts="${status_parts:+$status_parts }↓${behind}"
    [ -n "$status_parts" ] && git_status=" [$status_parts]"
fi

# Build status line
sep="${C_SEP} · ${C_RESET}"

if [ -n "$git_branch" ]; then
    dir_part="${C_DIR}${dir_name}/${C_RESET}${sep}${git_color}${git_branch}${git_status}${C_RESET}"
else
    dir_part="${C_DIR}${dir_name}/${C_RESET}"
fi

model_part="${C_MODEL}${model_name}${C_RESET}"
context_part="${C_CONTEXT}${current_k}${C_RESET}"
duration_part="${C_DURATION}${duration_display}${C_RESET}"

printf "%b%b%b%b%b%b%b" "$dir_part" "$sep" "$model_part" "$sep" "$context_part" "$sep" "$duration_part"
