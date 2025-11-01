.PHONY: frontend backend dev stop clean

frontend:
	@echo "Starting frontend (foreground)..."
	cd frontend && elm-land server

backend:
	@echo "Starting backend (foreground)..."
	cd backend && cabal v2-run backend-exe

dev:
	@echo "Starting frontend and backend in background, logs -> .logs/"
	@scripts/dev.sh

stop:
	@echo "Stopping dev processes (if any)"
	@scripts/stop-dev.sh || true

clean:
	@echo "Cleaning logs"
	@rm -rf .logs
