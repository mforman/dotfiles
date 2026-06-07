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

_cron_to_interval() {
  local min hour dom
  min=$(awk '{print $1}' <<< "$1")
  hour=$(awk '{print $2}' <<< "$1")
  dom=$(awk '{print $3}' <<< "$1")
  if [[ "$min" =~ ^\*/([0-9]+)$ && "$hour" == "*" && "$dom" == "*" ]]; then
    echo "${BASH_REMATCH[1]}m"
  elif [[ "$hour" =~ ^\*/([0-9]+)$ && "$dom" == "*" ]]; then
    echo "${BASH_REMATCH[1]}h"
  elif [[ "$hour" == "*" && "$dom" == "*" ]]; then
    echo "1h"
  elif [[ "$dom" == "*" ]]; then
    echo "daily"
  else
    echo "1x"
  fi
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
    else
      jq -n \
        --arg sid  "$session_id" \
        --arg cwd  "$_cwd" \
        --arg proj "$project" \
        --arg ts   "$tmux_session" \
        --arg now  "$now" \
        --arg p    "$prompt" \
        '{session_id:$sid, cwd:$cwd, project:$proj, status:"working", tmux_session:$ts, started_at:$now, last_activity:$now, last_prompt:$p}' \
        > "$state_file"
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
  PostToolUse)
    if [[ -f "$state_file" && $(jq -r '.status // ""' "$state_file") == "awaiting" ]]; then
      _update_file '.status = "working" | .last_activity = $now'
      _label "⚡" "$(jq -r '.last_prompt // ""' "$state_file")"
    fi
    tool=$(printf '%s' "$input" | jq -r '.tool_name // ""')
    case "$tool" in
      CronCreate)
        cron_expr=$(printf '%s' "$input" | jq -r '.tool_input.cron // ""')
        prompt_text=$(printf '%s' "$input" | jq -r '.tool_input.prompt // ""')
        job_id=$(printf '%s' "$input" | jq -r '.tool_response | fromjson | .id // empty' 2>/dev/null \
          || printf '%s' "$input" | jq -r '.tool_response // ""')
        interval=$(_cron_to_interval "$cron_expr")
        if [[ -n "$job_id" && -f "$state_file" ]]; then
          jq --arg id "$job_id" --arg interval "$interval" --arg prompt "$prompt_text" --arg now "$now" \
            '.loops = ((.loops // []) + [{id:$id, interval:$interval, prompt:$prompt, started_at:$now}])' \
            "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
        fi
        ;;
      CronDelete)
        job_id=$(printf '%s' "$input" | jq -r '.tool_input.id // ""')
        if [[ -n "$job_id" && -f "$state_file" ]]; then
          jq --arg id "$job_id" \
            '.loops = [(.loops // [])[] | select(.id != $id)]' \
            "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
        fi
        ;;
      ScheduleWakeup)
        delay=$(printf '%s' "$input" | jq -r '.tool_input.delaySeconds // 0')
        prompt_text=$(printf '%s' "$input" | jq -r '.tool_input.prompt // ""')
        next_fire=$(( $(date +%s) + delay ))
        mins=$(( (delay + 30) / 60 ))
        [[ $mins -gt 0 ]] && interval="${mins}m" || interval="<1m"
        if [[ -f "$state_file" ]]; then
          jq --arg interval "$interval" --arg prompt "$prompt_text" \
             --argjson next_fire "$next_fire" --arg now "$now" \
            '.loops = ([(.loops // [])[] | select(.id != "wakeup")] + [{id:"wakeup", interval:$interval, prompt:$prompt, next_fire:$next_fire, started_at:$now}])' \
            "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
        fi
        ;;
    esac
    ;;
  SessionEnd)
    rm -f "$state_file"
    _set_pane_status ""
    ;;
esac
