from fastapi import APIRouter, Depends, HTTPException, status, Query
from mysql.connector import Error
from database import get_db
from models import Task, TaskCreate, TaskUpdate, TaskStatus
from typing import List, Optional

router = APIRouter()

@router.post("/", response_model=Task, status_code=status.HTTP_201_CREATED)
def create_task(task: TaskCreate, user_id: int = Query(...), db=Depends(get_db)):
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
        
        # Check if project exists (if provided)
        if task.project_id:
            cursor.execute("SELECT * FROM projects WHERE project_id = %s", (task.project_id,))
            project = cursor.fetchone()
            
            if project is None:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Project not found"
                )
        
        # Insert the new task
        query = """
        INSERT INTO tasks (title, description, status, priority, due_date, project_id, user_id) 
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        """
        cursor.execute(
            query,
            (task.title, task.description, task.status, task.priority, 
             task.due_date, task.project_id, user_id)
        )
        connection.commit()
        
        # Get the newly created task
        task_id = cursor.lastrowid
        cursor.execute("SELECT * FROM tasks WHERE task_id = %s", (task_id,))
        new_task = cursor.fetchone()
        
        return new_task
    except Error as e:
        connection.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error: {str(e)}"
        )

@router.get("/", response_model=List[Task])
def read_tasks(
    user_id: Optional[int] = None,
    project_id: Optional[int] = None,
    status: Optional[TaskStatus] = None,
    skip: int = 0, 
    limit: int = 100, 
    db=Depends(get_db)
):
    connection, cursor = db
    
    try:
        query = "SELECT * FROM tasks WHERE 1=1"
        params = []
        
        # Add filters if provided
        if user_id:
            query += " AND user_id = %s"
            params.append(user_id)
        
        if project_id:
            query += " AND project_id = %s"
            params.append(project_id)
        
        if status:
            query += " AND status = %s"
            params.append(status)
        
        # Add pagination
        query += " LIMIT %s OFFSET %s"
        params.extend([limit, skip])
        
        cursor.execute(query, tuple(params))
        tasks = cursor.fetchall()
        
        return tasks
    except Error as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error: {str(e)}"
        )

@router.get("/{task_id}", response_model=Task)
def read_task(task_id: int, db=Depends(get_db)):
    connection, cursor = db
    
    try:
        cursor.execute("SELECT * FROM tasks WHERE task_id = %s", (task_id,))
        task = cursor.fetchone()
        
        if task is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Task not found"
            )
        
        return task
    except Error as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error: {str(e)}"
        )

@router.put("/{task_id}", response_model=Task)
def update_task(task_id: int, task_update: TaskUpdate, db=Depends(get_db)):
    connection, cursor = db
    
    try:
        # Check if task exists
        cursor.execute("SELECT * FROM tasks WHERE task_id = %s", (task_id,))
        existing_task = cursor.fetchone()
        
        if existing_task is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Task not found"
            )
        
        # Build update query based on provided fields
        update_fields = []
        params = []
        
        if task_update.title is not None:
            update_fields.append("title = %s")
            params.append(task_update.title)
        
        if task_update.description is not None:
            update_fields.append("description = %s")
            params.append(task_update.description)
        
        if task_update.status is not None:
            update_fields.append("status = %s")
            params.append(task_update.status)
        
        if task_update.priority is not None:
            update_fields.append("priority = %s")
            params.append(task_update.priority)
        
        if task_update.due_date is not None:
            update_fields.append("due_date = %s")
            params.append(task_update.due_date)
        
        if task_update.project_id is not None:
            # Check if project exists
            if task_update.project_id > 0:
                cursor.execute("SELECT * FROM projects WHERE project_id = %s", (task_update.project_id,))
                project = cursor.fetchone()
                
                if project is None:
                    raise HTTPException(
                        status_code=status.HTTP_404_NOT_FOUND,
                        detail="Project not found"
                    )
            
            update_fields.append("project_id = %s")
            params.append(task_update.project_id)
        
        # If no fields to update
        if not update_fields:
            return existing_task
        
        # Construct and execute update query
        query = f"UPDATE tasks SET {', '.join(update_fields)} WHERE task_id = %s"
        params.append(task_id)
        
        cursor.execute(query, tuple(params))
        connection.commit()
        
        # Get the updated task
        cursor.execute("SELECT * FROM tasks WHERE task_id = %s", (task_id,))
        updated_task = cursor.fetchone()
        
        return updated_task
    except Error as e:
        connection.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error: {str(e)}"
        )

@router.delete("/{task_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_task(task_id: int, db=Depends(get_db)):
    connection, cursor = db
    
    try:
        # Check if task exists
        cursor.execute("SELECT * FROM tasks WHERE task_id = %s", (task_id,))
        task = cursor.fetchone()
        
        if task is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Task not found"
            )
        
        # Delete the task
        cursor.execute("DELETE FROM tasks WHERE task_id = %s", (task_id,))
        connection.commit()
        
        return None
    except Error as e:
        connection.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error: {str(e)}"
        )