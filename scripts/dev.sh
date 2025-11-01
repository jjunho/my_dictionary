#!/usr/bin/env bash
set -euo pipefail

mkdir -p .logs

echo "Starting frontend... (logs -> .logs/frontend.log)"
(cd frontend && elm-land server > ../.logs/frontend.log 2>&1) &
FE_PID=$!
echo $FE_PID > .logs/frontend.pid

echo "Starting backend... (logs -> .logs/backend.log)"
(cd backend && cabal v2-run backend-exe > ../.logs/backend.log 2>&1) &
BE_PID=$!
echo $BE_PID > .logs/backend.pid

echo "Started frontend (PID=$FE_PID), backend (PID=$BE_PID)"
echo "Tailing logs (.logs/*.log). Press Ctrl-C to stop (processes keep running in background)."

tail -F .logs/*.log
