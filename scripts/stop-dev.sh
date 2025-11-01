#!/usr/bin/env bash
set -euo pipefail

if [ -d .logs ]; then
  for f in .logs/*.pid; do
    [ -f "$f" ] || continue
    pid=$(cat "$f" 2>/dev/null || echo "")
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
      echo "Killing PID $pid"
      kill "$pid" || true
    fi
    rm -f "$f"
  done
fi

echo "Stopped dev processes (logs remain in .logs/)"
