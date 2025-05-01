from pydantic import BaseModel, Field, EmailStr
from datetime import datetime, date
from typing import Optional, List
from enum import Enum

# Enums
class TaskStatus(str, Enum):
    todo = "todo"
    in_progress = "in_progress"
    completed = "completed"

class TaskPriority(str, Enum):
    low = "low"
    medium = "medium"
    high = "high"

# User models
class UserBase(BaseModel):
    username: str = Field(..., example="johndoe")
    email: EmailStr = Field(..., example="john@example.com")

class UserCreate(UserBase):
    password: str = Field(..., example="securepassword")

class User(UserBase):
    user_id: int
    created_at: datetime

    class Config:
        orm_mode = True

# Project models
class ProjectBase(BaseModel):
    title: str = Field(..., example="Personal Website")
    description: Optional[str] = Field(None, example="Redesign of my portfolio website")

class ProjectCreate(ProjectBase):
    pass

class Project(ProjectBase):
    project_id: int
    user_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        orm_mode = True

# Task models
class TaskBase(BaseModel):
    title: str = Field(..., example="Design homepage")
    description: Optional[str] = Field(None, example="Create wireframes for the homepage")
    status: TaskStatus = Field(default=TaskStatus.todo)
    priority: TaskPriority = Field(default=TaskPriority.medium)
    due_date: Optional[date] = Field(None, example="2025-05-15")
    project_id: Optional[int] = None

class TaskCreate(TaskBase):
    pass

class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    status: Optional[TaskStatus] = None
    priority: Optional[TaskPriority] = None
    due_date: Optional[date] = None
    project_id: Optional[int] = None

class Task(TaskBase):
    task_id: int
    user_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        orm_mode = True