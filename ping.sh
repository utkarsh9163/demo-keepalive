#!/usr/bin/env bash
# Visits the URLs in the given file (default urls.txt) in parallel, following each line's rule:
#
#   https://example.com/health                          daily: pinged 10:00 AM-11:59 PM IST
#   https://example.com/health  until=2026-10-11 20:00  demo window: pinged day and night until
#                                                       that IST time, then not at all
#
# Exits 1 if any pinged URL doesn't answer with 2xx/3xx, so the Actions run shows red.
# India time is computed from UTC (+5:30), so this works the same on any machine.
# For testing, NOW_EPOCH=<unix seconds> overrides the current time.
set -u
list="${1:-urls.txt}"
DAILY_START="${DAILY_START:-10:00}" # IST, inclusive
DAILY_END="${DAILY_END:-23:59}"     # IST, inclusive

now=${NOW_EPOCH:-$(date -u +%s)}
ist_min=$(( ((now + 19800) / 60) % 1440 ))   # minutes since midnight, IST
to_min() { local h=${1%%:*} m=${1##*:}; echo $((10#$h * 60 + 10#$m)); }
start_min=$(to_min "$DAILY_START")
end_min=$(to_min "$DAILY_END")
now_ist="$(date -u -d "@$((now + 19800))" '+%Y-%m-%d %H:%M')"
echo "Now: $now_ist IST (daily hours $DAILY_START-$DAILY_END)"

results="$(mktemp -d)"
pinged=0

while IFS= read -r raw || [ -n "$raw" ]; do
  line="${raw//$'\r'/}"
  line="${line#"${line%%[![:space:]]*}"}"   # trim leading spaces
  line="${line%"${line##*[![:space:]]}"}"   # trim trailing spaces
  [ -z "$line" ] && continue
  [ "${line:0:1}" = "#" ] && continue

  url="${line%%[[:space:]]*}"
  until=""
  case "$line" in *until=*) until="${line#*until=}" ;; esac

  if [ -n "$until" ]; then
    if ! until_epoch=$(date -u -d "$until +0530" +%s 2>/dev/null); then
      echo "BAD   $url  (can't read until=$until; use YYYY-MM-DD HH:MM in IST)"
      echo "000  $url" > "$results/bad-$pinged-$RANDOM"
      continue
    fi
    if [ "$now" -ge "$until_epoch" ]; then
      echo "skip  $url  (demo window ended $until IST)"
      continue
    fi
    echo "ping  $url  (demo window until $until IST)"
  else
    if [ "$ist_min" -lt "$start_min" ] || [ "$ist_min" -gt "$end_min" ]; then
      echo "skip  $url  (outside daily hours)"
      continue
    fi
    echo "ping  $url  (daily)"
  fi

  pinged=$((pinged + 1))
  # In parallel, so one slow service waking up doesn't delay the rest.
  (
    code=$(curl -s -o /dev/null -w "%{http_code}" --retry 2 --retry-delay 10 --max-time 90 "$url")
    echo "$code  $url" > "$results/$pinged"
  ) &
done < "$list"
wait

if ! ls "$results"/* >/dev/null 2>&1; then
  echo "Nothing to ping right now."
  exit 0
fi

echo "Results:"
cat "$results"/*
if grep -qvE '^[23][0-9][0-9] ' "$results"/*; then
  echo "Some URLs failed."
  exit 1
fi
echo "All $pinged URL(s) OK."
