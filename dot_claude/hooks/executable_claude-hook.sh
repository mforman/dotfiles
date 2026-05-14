#!/usr/bin/env bash
set -euo pipefail

event="${1:-}"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/claude/sessions"
mkdir -p "$state_dir"

input=$(cat)
session_id=$(printf '%s' "$input" | jq -r '.session_id // empty')
[[ -z "$session_id" ]] && exit 0

state_file="$state_dir/${session_id}.json"
now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

_cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
[[ -z "$_cwd" ]] && _cwd="$PWD"
project=$(basename "$_cwd")

tmux_session=""
if [[ -n "${TMUX:-}" ]]; then
  tmux_session=$(tmux display-message -p '#S' 2>/dev/null || true)
fi

_update_file() {
  [[ -f "$state_file" ]] || return 0
  jq "$1" --arg now "$now" "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
}

_set_pane_status() {
  [[ -n "${TMUX_PANE:-}" ]] || return 0
  if [[ -z "$1" ]]; then
    tmux set-option -p -t "$TMUX_PANE" -u @claude_status 2>/dev/null || true
  else
    tmux set-option -p -t "$TMUX_PANE" @claude_status "$1" 2>/dev/null || true
  fi
}

_label() {
  local icon="$1" text="$2"
  text="${text//$'\n'/ }"
  [[ ${#text} -gt 50 ]] && text="${text:0:47}..."
  _set_pane_status "$icon $text"
}

case "$event" in
  SessionStart)
    jq -n \
      --arg sid  "$session_id" \
      --arg cwd  "$_cwd" \
      --arg proj "$project" \
      --arg ts   "$tmux_session" \
      --arg now  "$now" \
      '{session_id:$sid, cwd:$cwd, project:$proj, status:"idle", tmux_session:$ts, started_at:$now, last_activity:$now, last_prompt:""}' \
      > "$state_file"
    _label "·" "idle"
    ;;
  UserPromptSubmit)
    prompt=$(printf '%s' "$input" | jq -r '.prompt // ""')
    if [[ -f "$state_file" ]]; then
      jq --arg now "$now" --arg p "$prompt" \
        '.status = "working" | .last_activity = $now | .last_prompt = $p' \
        "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
    fi
    _label "⚡" "$prompt"
    ;;
  Stop)
    _update_file '.status = "idle" | .last_activity = $now'
    last_prompt=""
    [[ -f "$state_file" ]] && last_prompt=$(jq -r '.last_prompt // ""' "$state_file")
    _label "·" "${last_prompt:-idle}"
    ;;
  Notification)
    _update_file '.status = "awaiting" | .last_activity = $now'
    msg=$(printf '%s' "$input" | jq -r '.message // "awaiting"')
    _label "?" "$msg"
    ;;
  SessionEnd)
    rm -f "$state_file"
    _set_pane_status ""
    ;;
esac
