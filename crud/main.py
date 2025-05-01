from fastapi import FastAPI, Depends, HTTPException, status
from database import get_db
from models import User, Project, Task
from routes import users, projects, tasks
import uvicorn

app = FastAPI(title="Task Manager API", 
              description="A simple CRUD API for managing tasks and projects")

# Include routers
app.include_router(users.router, prefix="/api/users", tags=["users"])
app.include_router(projects.router, prefix="/api/projects", tags=["projects"])
app.include_router(tasks.router, prefix="/api/tasks", tags=["tasks"])

@app.get("/")
def read_root():
    return {"message": "Welcome to Task Manager API"}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)