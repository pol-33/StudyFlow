# StudyFlow

Web platform for students to manage projects, tasks, and documents in one place — with JWT authentication, organized workflows, and a modern Vue 3 UI.

![Django](https://img.shields.io/badge/Django-5.2-green) ![Vue](https://img.shields.io/badge/Vue-3.5-brightgreen) ![Vite](https://img.shields.io/badge/Vite-7-purple) ![Docker](https://img.shields.io/badge/Docker-Compose-blue)

## Table of Contents
- Overview
- Features
- Tech Stack
- Requirements
- Quick Start (Docker)
- Configuration
- Development (without Docker)
- Usage
- API & Resources
- Changelog
- Contributing
- License

## Overview
StudyFlow centralizes your study workflow:
- Create projects and organize tasks.
- Attach documents to tasks.
- Authenticate with JWT; access control enforced via DRF.
- Responsive SPA built with Vue 3, Vite, Pinia, and Element Plus.

## Features
- Project and task management with nested REST endpoints.
- Document upload and management.
- JWT authentication with access/refresh tokens.
- CORS configured for local dev and production.
- Dockerized dev and prod environments with health checks and non‑root containers.

## Tech Stack
- Backend: Django 5, DRF, SimpleJWT, CORS Headers
- Frontend: Vue 3, Vite 7, Pinia, Element Plus, Axios
- Infrastructure: Docker, Docker Compose, Nginx (SPA), Gunicorn

## Requirements
- Python 3.12+
- Node.js 20+
- npm 10+
- Docker Engine 24+ and Docker Compose v2

## Quick Start (Docker)
Recommended for a fast setup with hot-reload in dev and optimized serving in prod.

### Development
```bash
docker compose --profile dev up --build
```
- Frontend: `http://localhost:5173`
- Backend API: `http://localhost:8000`

### Production
```bash
docker compose --profile prod up --build
```
- Frontend: `http://localhost:8080`
- Backend API: `http://localhost:8000`

### Tear Down
```bash
docker compose down
```

## Configuration
### Frontend (`frontend/.env`)
- `VITE_API_BASE_URL`: Base URL for the backend API used by `src/services/api.js`.
  - Defined in `frontend/.env`, loaded by Vite at build and dev time.
  - Compose now references `frontend/.env` via `env_file` and validates presence before starting.

### Backend (`backend/.env`)
- `SECRET_KEY`: Django secret; required for production.
- `DEBUG`: `True` or `False` (Compose sets appropriately per profile).
- `ALLOWED_HOSTS`: Comma-separated (e.g., `localhost,127.0.0.1`).
- `CORS_ALLOWED_ORIGINS`: Comma-separated allowed origins.
- `ACCESS_TOKEN_LIFETIME_MINUTES`, `REFRESH_TOKEN_LIFETIME_DAYS`: SimpleJWT lifetimes.
- Media: `MEDIA_ROOT` defaults to `backend/media` and is persisted via a Docker volume in dev.

### Environment Loading & Precedence
- Each service has its own `.env` file: `backend/.env`, `frontend/.env`.
- Compose loads service envs with `env_file`. In Compose, `environment` entries override `env_file` values.
- Inside the backend, Django loads `backend/.env` via `python-dotenv`.
- Frontend dev and build read `frontend/.env` via Vite.
- Host shell env can override Compose variables; prefer `env_file` for reproducibility.

### Validation
- Backend entrypoint validates critical variables:
  - Fails if `DEBUG=False` and `SECRET_KEY` is missing.
- Frontend dev service checks that `VITE_API_BASE_URL` exists in `frontend/.env` before starting.

### Notes
- CORS defaults allow local frontend dev URLs (`http://localhost:5173`, `http://127.0.0.1:5173`) and prod (`http://localhost:8080`) via Compose.
- SQLite is used by default; migrations are required in non-Docker dev.

## Development (without Docker)
### Backend (Django)
```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env
python manage.py migrate
python manage.py runserver
```
Backend: `http://127.0.0.1:8000`

### Frontend (Vue 3)
```bash
cd frontend
npm install
cp .env.example .env
npm run dev
```
Frontend: `http://localhost:5173`

## Usage
1. Open `http://localhost:5173`.
2. Register a new user or log in.
3. Create a project and add tasks.
4. Upload documents to tasks.

## API & Resources
- JWT Endpoints: `api/auth/token/`, `api/auth/token/refresh/` (`backend/studyflow/urls.py`)
- Project/Task/Document endpoints are nested (`backend/api/urls.py`).
- Postman collection: `backend/StudyFlow_Postman_Collection.json`
- Frontend API client uses `VITE_API_BASE_URL` (`frontend/src/services/api.js`).

## Changelog
### 2025-11-17
- Added comprehensive Dockerization:
  - Frontend multi-stage Dockerfile (dev via Vite, prod via Nginx on 8080).
  - Backend multi-stage Dockerfile (dev via Django runserver, prod via Gunicorn on 8000).
  - `docker-compose.yml` with `dev` and `prod` profiles, health checks, env vars, volumes, restart policies.
- Security hardening: non-root users, minimal base images.
- Updated documentation to reflect new setup and usage.

## Contributing
- Fork the repo and create a feature branch from `main`.
- Follow existing code patterns and project structure.
- Backend: add or update tests under `backend/api/tests.py` when introducing changes.
- Run locally via Docker profiles or native dev setup before opening a PR.
- Submit a pull request with a clear description and rationale.


## License
Este proyecto está bajo la licencia especificada en el archivo LICENSE.
