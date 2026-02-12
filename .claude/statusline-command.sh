#!/bin/bash
# Claude Code Statusline - Two-line layout with context bar, cost, and git caching

input=$(cat)

# ── Extract fields ──────────────────────────────────────────────────────────
model=$(echo "$input" | jq -r '.model.display_name // "?"')
dir=$(echo "$input" | jq -r '.workspace.current_dir // "~"')
dir_name=$(basename "$dir")
pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
lines_add=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_rm=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
style=$(echo "$input" | jq -r '.output_style.name // empty')

# ── Colors ──────────────────────────────────────────────────────────────────
C_DIR="\033[38;5;51m"
C_MODEL="\033[38;5;105m"
C_STYLE="\033[38;5;243m"
C_GREEN="\033[38;5;154m"
C_YELLOW="\033[38;5;220m"
C_RED="\033[38;5;203m"
C_LINES_ADD="\033[38;5;154m"
C_LINES_RM="\033[38;5;203m"
C_DUR="\033[38;5;245m"
C_GIT_CLEAN="\033[38;5;154m"
C_GIT_DIRTY="\033[38;5;222m"
C_SEP="\033[38;5;239m"
C_RESET="\033[0m"

sep="${C_SEP} · ${C_RESET}"

# ── Git info (cached, 5s TTL) ──────────────────────────────────────────────
CACHE_FILE="/tmp/claude-statusline-git-cache"
CACHE_DIR_FILE="/tmp/claude-statusline-git-cache-dir"
CACHE_MAX_AGE=5

cache_stale() {
    [ ! -f "$CACHE_FILE" ] || [ ! -f "$CACHE_DIR_FILE" ] || \
    [ "$(cat "$CACHE_DIR_FILE" 2>/dev/null)" != "$dir" ] || \
    [ $(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0))) -gt $CACHE_MAX_AGE ]
}

if cache_stale; then
    if git -C "$dir" rev-parse --git-dir >/dev/null 2>&1; then
        branch=$(git -C "$dir" --no-optional-locks branch --show-current 2>/dev/null || echo "detached")
        untracked=$(git -C "$dir" --no-optional-locks ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
        staged=$(git -C "$dir" --no-optional-locks diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
        modified=$(git -C "$dir" --no-optional-locks diff --numstat 2>/dev/null | wc -l | tr -d ' ')
        ab=$(git -C "$dir" --no-optional-locks rev-list --left-right --count @{upstream}...HEAD 2>/dev/null || echo "0 0")
        behind=$(echo "$ab" | awk '{print $1}')
        ahead=$(echo "$ab" | awk '{print $2}')
        echo "${branch}|${untracked}|${staged}|${modified}|${ahead}|${behind}" > "$CACHE_FILE"
    else
        echo "" > "$CACHE_FILE"
    fi
    echo "$dir" > "$CACHE_DIR_FILE"
fi

git_part=""
IFS='|' read -r branch untracked staged modified ahead behind < "$CACHE_FILE"
if [ -n "$branch" ]; then
    git_color="$C_GIT_CLEAN"
    status_parts=""
    [ "$untracked" -gt 0 ] 2>/dev/null && status_parts="${status_parts}?${untracked}" && git_color="$C_GIT_DIRTY"
    [ "$staged" -gt 0 ] 2>/dev/null && status_parts="${status_parts:+$status_parts }+${staged}" && git_color="$C_GIT_DIRTY"
    [ "$modified" -gt 0 ] 2>/dev/null && status_parts="${status_parts:+$status_parts }!${modified}" && git_color="$C_GIT_DIRTY"
    [ "$ahead" -gt 0 ] 2>/dev/null && status_parts="${status_parts:+$status_parts }↑${ahead}"
    [ "$behind" -gt 0 ] 2>/dev/null && status_parts="${status_parts:+$status_parts }↓${behind}"
    [ -n "$status_parts" ] && branch="${branch} [${status_parts}]"
    git_part="${sep}${git_color}${branch}${C_RESET}"
fi

# ── Format duration ─────────────────────────────────────────────────────────
if [ "$duration_ms" -gt 0 ] 2>/dev/null; then
    secs=$((duration_ms / 1000))
    if [ $secs -ge 3600 ]; then
        dur="$((secs / 3600))h$(((secs % 3600) / 60))m"
    elif [ $secs -ge 60 ]; then
        dur="$((secs / 60))m$((secs % 60))s"
    else
        dur="${secs}s"
    fi
else
    dur="0s"
fi

# ── Context bar (10 chars, color by threshold) ──────────────────────────────
[ -z "$pct" ] || [ "$pct" = "null" ] && pct=0
if [ "$pct" -ge 90 ] 2>/dev/null; then
    bar_color="$C_RED"
elif [ "$pct" -ge 70 ] 2>/dev/null; then
    bar_color="$C_YELLOW"
else
    bar_color="$C_GREEN"
fi

filled=$((pct * 10 / 100))
empty=$((10 - filled))
bar=""
[ "$filled" -gt 0 ] && bar=$(printf "%${filled}s" | tr ' ' '▓')
[ "$empty" -gt 0 ] && bar="${bar}$(printf "%${empty}s" | tr ' ' '░')"

# ── Style tag ───────────────────────────────────────────────────────────────
style_part=""
[ -n "$style" ] && [ "$style" != "null" ] && [ "$style" != "default" ] && \
    style_part="${sep}${C_STYLE}${style}${C_RESET}"

# ── Output ──────────────────────────────────────────────────────────────────
# Line 1: workspace context
printf "%b" "${C_DIR}${dir_name}/${C_RESET}${git_part}${sep}${C_MODEL}${model}${C_RESET}${style_part}"
echo ""
# Line 2: session metrics
printf "%b" "${bar_color}${bar}${C_RESET} ${pct}%${sep}${C_LINES_ADD}+${lines_add}${C_RESET}/${C_LINES_RM}-${lines_rm}${C_RESET}${sep}${C_DUR}${dur}${C_RESET}"
echo ""
