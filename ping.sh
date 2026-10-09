#!/usr/bin/env bash
# Visits every URL in the given file (default urls.txt) in parallel.
# Exits 1 if any URL doesn't answer with 2xx/3xx, so the Actions run shows red.
set -u
list="${1:-urls.txt}"
results="$(mktemp -d)"
i=0

while IFS= read -r line || [ -n "$line" ]; do
  url="${line//$'\r'/}"
  url="${url#"${url%%[![:space:]]*}"}"   # trim leading spaces
  url="${url%"${url##*[![:space:]]}"}"   # trim trailing spaces
  [ -z "$url" ] && continue
  [ "${url:0:1}" = "#" ] && continue
  i=$((i + 1))
  # In parallel, so one slow service waking up doesn't delay the rest.
  (
    code=$(curl -s -o /dev/null -w "%{http_code}" --retry 2 --retry-delay 10 --max-time 90 "$url")
    echo "$code  $url" > "$results/$i"
  ) &
done < "$list"
wait

if [ "$i" -eq 0 ]; then
  echo "No URLs in $list"
  exit 0
fi

cat "$results"/*
if grep -qvE '^[23][0-9][0-9] ' "$results"/*; then
  echo "Some URLs failed."
  exit 1
fi
echo "All $i URL(s) OK."
