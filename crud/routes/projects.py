from fastapi import APIRouter, Depends, HTTPException, status, Query
from mysql.connector import Error
from database import get_db
from models import Project, ProjectCreate
from typing import List

router = APIRouter()

@router.post("/", response_model=Project, status_code=status.HTTP_201_CREATED)
def create_project(project: ProjectCreate, user_id: int = Query(...), db=Depends(get_db)):
    connection, cursor = db
    
    try:
        # Check if user exists
        cursor.execute("SELECT * FROM users WHERE user_id = %s", (user_id,))
        user = cursor.fetchone()
        
        if user is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        # Insert the new project
        cursor.execute(
            "INSERT INTO projects (title, description, user_id) VALUES (%s, %s, %s)",
            (project.title, project.description, user_id)
        )
        connection.commit()
        
        # Get the newly created project
        project_id = cursor.lastrowid
        cursor.execute("SELECT * FROM projects WHERE project_id = %s", (project_id,))
        new_project = cursor.fetchone()
        
        return new_project
    except Error as e:
        connection.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error: {str(e)}"
        )

@router.get("/", response_model=List[Project])
def read_projects(user_id: int = None, skip: int = 0, limit: int = 100, db=Depends(get_db)):
    connection, cursor = db
    
    try:
        if user_id:
            # Get projects for a specific user
            cursor.execute("SELECT * FROM projects WHERE user_id = %s LIMIT %s OFFSET %s", 
                          (user_id, limit, skip))
        else:
            # Get all projects
            cursor.execute("SELECT * FROM projects LIMIT %s OFFSET %s", (limit, skip))
            
        projects = cursor.fetchall()
        return projects
    except Error as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error: {str(e)}"
        )

@router.get("/{project_id}", response_model=Project)
def read_project(project_id: int, db=Depends(get_db)):
    connection, cursor = db
    
    try:
        cursor.execute("SELECT * FROM projects WHERE project_id = %s", (project_id,))
        project = cursor.fetchone()
        
        if project is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Project not found"
            )
        
        return project
    except Error as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error: {str(e)}"
        )

@router.put("/{project_id}", response_model=Project)
def update_project(project_id: int, project: ProjectCreate, db=Depends(get_db)):
    connection, cursor = db
    
    try:
        # Check if project exists
        cursor.execute("SELECT * FROM projects WHERE project_id = %s", (project_id,))
        existing_project = cursor.fetchone()
        
        if existing_project is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Project not found"
            )
        
        # Update the project
        cursor.execute(
            "UPDATE projects SET title = %s, description = %s WHERE project_id = %s",
            (project.title, project.description, project_id)
        )
        connection.commit()
        
        # Get the updated project
        cursor.execute("SELECT * FROM projects WHERE project_id = %s", (project_id,))
        updated_project = cursor.fetchone()
        
        return updated_project
    except Error as e:
        connection.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error: {str(e)}"
        )

@router.delete("/{project_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_project(project_id: int, db=Depends(get_db)):
    connection, cursor = db
    
    try:
        # Check if project exists
        cursor.execute("SELECT * FROM projects WHERE project_id = %s", (project_id,))
        project = cursor.fetchone()
        
        if project is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Project not found"
            )
        
        # Delete the project
        cursor.execute("DELETE FROM projects WHERE project_id = %s", (project_id,))
        connection.commit()
        
        return None
    except Error as e:
        connection.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error: {str(e)}"
        )