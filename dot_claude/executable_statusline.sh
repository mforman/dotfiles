#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
TRANSCRIPT=$(echo "$input" | jq -r '.transcript_path // ""')

FIVE_PCT=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // 0' | cut -d. -f1)
FIVE_RESET=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // 0')
SEVEN_PCT=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // 0' | cut -d. -f1)
SEVEN_RESET=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // 0')

PLUGINS=$(jq -rs '
  [.[] | (.enabledPlugins // {}) | to_entries[] | select(.value==true) | .key | split("@")[0]]
  | unique | join(",")
' \
  <(cat ~/.claude/settings.json 2>/dev/null || echo '{}') \
  <(cat "$(pwd)/.claude/settings.json" 2>/dev/null || echo '{}') \
)

SKILLS=""
if [[ -n "$TRANSCRIPT" && -f "$TRANSCRIPT" ]]; then
  SKILLS=$(grep -oP '"skill"\s*:\s*"\K[^"]+' "$TRANSCRIPT" 2>/dev/null \
    | sed 's/.*://' | sort -u | tr '\n' ',' | sed 's/,$//')
fi

fmt_delta() {
  local secs=$(( $1 - $(date +%s) ))
  (( secs <= 0 )) && echo "now" && return
  local d=$(( secs / 86400 )) h=$(( (secs % 86400) / 3600 )) m=$(( (secs % 3600) / 60 ))
  local out=""
  (( d > 0 )) && out="${d}d"
  (( h > 0 )) && out="${out}${h}h"
  (( d == 0 && m > 0 )) && out="${out}${m}m"
  echo "${out:-<1m}"
}

CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; RESET='\033[0m'

if [ "$PCT" -ge 90 ]; then BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

FILLED=$((PCT / 10)); EMPTY=$((10 - FILLED))
BAR=$(printf "%${FILLED}s" | tr ' ' '█')$(printf "%${EMPTY}s" | tr ' ' '░')

MINS=$((DURATION_MS / 60000)); SECS=$(((DURATION_MS % 60000) / 1000))

BRANCH=""
git rev-parse --git-dir > /dev/null 2>&1 && BRANCH=" | 🌿 $(git branch --show-current 2>/dev/null)"

echo -e "${CYAN}[$MODEL]${RESET} 📁 ${DIR##*/}$BRANCH"
COST_FMT=$(printf '$%.2f' "$COST")
echo -e "🧠 ${BAR_COLOR}${BAR}${RESET} ${PCT}% | ${YELLOW}${COST_FMT}${RESET} | ⏱️ ${MINS}m ${SECS}s"

join_pipe() { local out="$1"; shift; for x in "$@"; do out+=" | $x"; done; echo -e "$out"; }

RL=()
if [[ "$FIVE_PCT" -gt 0 || "$FIVE_RESET" -gt 0 ]]; then
  if [ "$FIVE_PCT" -ge 90 ]; then C="$RED"
  elif [ "$FIVE_PCT" -ge 70 ]; then C="$YELLOW"
  else C="$GREEN"; fi
  RL+=("${C}5h: ${FIVE_PCT}%${RESET} ↻$(fmt_delta "$FIVE_RESET")")
fi
if [[ "$SEVEN_PCT" -gt 0 || "$SEVEN_RESET" -gt 0 ]]; then
  RL+=("7d: ${SEVEN_PCT}% ↻$(fmt_delta "$SEVEN_RESET")")
fi
[[ ${#RL[@]} -gt 0 ]] && { rl=$(join_pipe "${RL[@]}"); echo -e "⚡ $rl"; }

EXTRAS=()
[[ -n "$PLUGINS" ]] && EXTRAS+=("🔌 $PLUGINS")
[[ -n "$SKILLS"  ]] && EXTRAS+=("🛠 $SKILLS")
[[ ${#EXTRAS[@]} -gt 0 ]] && join_pipe "${EXTRAS[@]}"
