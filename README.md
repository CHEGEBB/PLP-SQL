# Task Manager API

A simple CRUD API for managing tasks, projects and users built with FastAPI and MySQL.

## Features

- User management (create, read, delete)
- Project management (create, read, update, delete)
- Task management with filtering capabilities (create, read, update, delete)
- MySQL database integration.

## Project Structure

```
task-manager-api/
├── main.py                  # Entry point for the application
├── database.py              # Database connection management
├── models.py                # Pydantic models
├── routes/                  # API routes
│   ├── __init__.py
│   ├── users.py
│   ├── projects.py
│   └── tasks.py
├── schema.sql               # Database schema
├── requirements.txt         # Dependencies
└── .env.example             # Environment variables example
```

## Setup

### 1. Clone the repository

```bash
git clone https://github.com/yourusername/task-manager-api.git
cd task-manager-api
```

### 2. Set up the virtual environment

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 3. Set up the database

```bash
# Create a MySQL database
mysql -u root -p < schema.sql
```

### 4. Configure environment variables

```bash
cp .env.example .env
# Edit .env with your database credentials
```

### 5. Run the application

```bash
uvicorn main:app --reload
```

The API will be available at http://localhost:8000

## API Documentation

Once the application is running, you can access:
- Interactive API documentation: http://localhost:8000/docs
- Alternative API documentation: http://localhost:8000/redoc

## API Endpoints

### Users
- `POST /api/users` - Create a new user
- `GET /api/users` - List all users
- `GET /api/users/{user_id}` - Get a specific user
- `DELETE /api/users/{user_id}` - Delete a user

### Projects
- `POST /api/projects` - Create a new project
- `GET /api/projects` - List all projects (can filter by user_id)
- `GET /api/projects/{project_id}` - Get a specific project
- `PUT /api/projects/{project_id}` - Update a project
- `DELETE /api/projects/{project_id}` - Delete a project

### Tasks
- `POST /api/tasks` - Create a new task
- `GET /api/tasks` - List all tasks (can filter by user_id, project_id, status)
- `GET /api/tasks/{task_id}` - Get a specific task
- `PUT /api/tasks/{task_id}` - Update a task
- `DELETE /api/tasks/{task_id}` - Delete a task