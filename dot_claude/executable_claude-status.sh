#!/usr/bin/env bash
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/claude/sessions"
[[ -d "$state_dir" ]] || exit 0

working=0 awaiting=0 idle=0
declare -A awaiting_sessions=()
now=$(date +%s)
cutoff=$((now - 3600))

for f in "$state_dir"/*.json; do
  [[ -f "$f" ]] || continue
  mtime=$(stat -f %m "$f" 2>/dev/null || stat -c %Y "$f" 2>/dev/null || echo 0)
  if [[ "$mtime" -lt "$cutoff" ]]; then
    rm -f "$f"
    continue
  fi
  read -r status tsess < <(jq -r '"\(.status // "") \(.tmux_session // "?")"' "$f" 2>/dev/null || echo " ")
  case "$status" in
    working)  working=$((working + 1)) ;;
    awaiting) awaiting=$((awaiting + 1)); awaiting_sessions["$tsess"]=1 ;;
    idle)     idle=$((idle + 1)) ;;
  esac
done

parts=()
[[ $working -gt 0 ]] && parts+=("${working}⚡")
if [[ $awaiting -gt 0 ]]; then
  _oifs="$IFS"; IFS=,
  parts+=("${awaiting}?(${!awaiting_sessions[*]})")
  IFS="$_oifs"
fi
[[ $idle -gt 0 ]] && parts+=("${idle}·")

[[ ${#parts[@]} -eq 0 ]] && exit 0
printf '%s ' "${parts[*]}"
